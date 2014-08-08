=begin
JRubyFX - Write JavaFX and FXML in Ruby
Copyright (C) 2013 The JRubyFX Team

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end

# DO NOT INCLUDE ANY JRUBYFX CODE DIRECTLY!!! THIS IS A RAKEFILE EXTENSION!!!
require 'open-uri'
require 'rake'
require 'tmpdir'
require "pathname"

module JRubyFX
  # This module contains utilities to jarify an app, and can be used in a rakefile or a running app.
  module Tasks
    extend Rake::DSL
    # Base URL of JRuby-complete.jar download location
    BASE_URL='http://jruby.org.s3.amazonaws.com/downloads'

    ##
    # Downloads the jruby-complete jar file for `jruby_version` and save in
    # ~/.jruby-jar/jruby-complete.jar unless it already exits. If the jar is
    # corrupt or an older version, set force to true to delete and re-download
    def download_jruby(jruby_version, force=false)
      dist = "#{Dir.home}/.jruby-jar"
      unless force || (File.exists?("#{dist}/jruby-complete-#{jruby_version}.jar") && File.size("#{dist}/jruby-complete-#{jruby_version}.jar") > 0)
        mkdir_p dist
        base_dir = Dir.pwd
        cd dist
        $stderr.puts "JRuby complete jar not found. Downloading... (May take awhile)"
        download(jruby_version)
        cd base_dir
      end
    end

    ##
    # Creates a full jar from the given source pattern (must be a pattern to match
    # files), with the given main script as the script to launch when the jarfile
    # is run. The output jar is saved in the `target` dir, which also doubles as a
    # temporary work dir. `jar` is the executable that makes jars. If `target` is
    # nill then a random temporary directory is created, and output_jar is the
    # full path to the jar file to save
    def jarify_jrubyfx(src="src/*" ,main_script=nil, target="target", output_jar="jrubyfx-app.jar", opts = {})
      if target_was_nil = target == nil
        target = Dir.mktmpdir("jrubyfx")
        final_jar = output_jar
        output_jar = File.basename output_jar
      end
      # set defaults
      opts = {file_filter: ->(f){true},jar: "jar"}.merge(opts)

      mkdir_p target

      #copy jruby jar file in, along with script and our rb files
      cp "#{ENV['HOME']}/.jruby-jar/jruby-complete-#{opts[:version] || JRUBY_VERSION}.jar", "#{target}/#{output_jar}"

      #copy source in
      FileList[src].each do |iv_srv|
        cp_r iv_srv, "#{target}/#{File.basename(iv_srv)}" if (main_script == nil || main_script != iv_srv) && opts[:file_filter].call(iv_srv)
      end
      cp main_script, "#{target}/jar-bootstrap.rb" unless main_script == nil

      unless File.exists? "#{target}/jar-bootstrap.rb"
        $stderr.puts "@"*79
        $stderr.puts "@#{"!!!WARNING!!!".center(79-2)}@"
        $stderr.puts "@#{"jar-bootstrap.rb NOT FOUND!".center(79-2)}@"
        $stderr.puts "@#{"Did you set main_src= or have jar-bootstrap in src= ?".center(79-2)}@"
        $stderr.puts "@"*79
      end

      #copy our libs in
      FileList["#{File.dirname(__FILE__)}/*"].each do |librb|
        cp_r librb, target
      end

      fxml_loader_path = nil
      # this will find it if we are calling ruby -I whatever
      $LOAD_PATH.each do |pth|
        if File.exist? File.join(pth, "jrubyfx-fxmlloader.rb")
          fxml_loader_path = pth
          break
        end
      end

      # default to gems
      unless fxml_loader_path
        fxml_loader_path = File.join(Gem::Specification.find_by_path('jrubyfx-fxmlloader').full_gem_path, "lib")
      end
      #copy fxmlloader in
      FileList["#{fxml_loader_path}/*"].each do |librb|
        cp_r librb, target
      end

      # edit the jar
      base_dir = Dir.pwd
      cd target
      sh "#{opts[:jar]} ufe '#{output_jar}' org.jruby.JarBootstrapMain *"
      chmod 0775, output_jar
      cd base_dir

      if target_was_nil
        mv "#{target}/#{output_jar}", final_jar
        rm_rf target
      end
    end

    # Uses Java 8 Ant task to create a native bundle (exe, deb, rpm, etc) of the
    # specified jar-ified ruby script
    def native_bundles(base_dir=Dir.pwd, output_jar, verbosity, app_name)
      # Currently only JDK8 will package up JRuby apps. In the near
      # future the necessary tools will be in maven central and
      # we can download them as needed, so this can be changed then.
      # this is in format "1.7.0_11-b21", check for all jdk's less than 8
      if ENV_JAVA["java.runtime.version"].match(/^1\.[0-7]{1}\..*/)
        raise "You must install JDK 8 to use the native-bundle packaging tools. You can still create an executable jar, though."
      end

      # the native bundling uses ant
      require "ant"

      output_jar = Pathname.new(output_jar)
      dist_dir = output_jar.parent
      jar_name = File.basename(output_jar)
      out_name = File.basename(output_jar, '.*')

      # Can't access the "fx" xml namespace directly, so we get it via __send__.
      ant do
        taskdef(resource: "com/sun/javafx/tools/ant/antlib.xml",
          uri: "javafx:com.sun.javafx.tools.ant",
          classpath: ".:${java.home}/../lib/ant-javafx.jar")
        __send__("javafx:com.sun.javafx.tools.ant:deploy", nativeBundles: "all",
          width: "100", height: "100", outdir: "#{base_dir}/build/",
          outfile: out_name, verbose: verbosity) do
          application(mainClass: "org.jruby.JarBootstrapMain", name: app_name)
          resources do
            fileset(dir: dist_dir) do
              include name: jar_name
            end
          end
        end
      end

      # These webstart files don't work, and the packager doesn't have an option to
      # disable them, so remove them so the user isn't confused.
      # FIXME: jnlp webstart
      full_build_dir = "#{base_dir}/build/"
      rm FileList["#{full_build_dir}*.html","#{full_build_dir}*.jnlp"]
    end

    def compile(cmdline)
      require 'jrubyfx/compiler_app'
      $JRUBYFX_AOT_COMPILING = true
      CompilerApp.launch(*cmdline) # must use this to provide a full javafx environ so controls will build properly
    end


    private
    def download(version_string) #:nodoc:
      File.open("jruby-complete-#{version_string}.jar","wb") do |f|
        f.write(open("#{BASE_URL}/#{version_string}/jruby-complete-#{version_string}.jar").read)
      end
    end

    module_function :jarify_jrubyfx
    module_function :download_jruby
    module_function :native_bundles
    module_function :download
    module_function :compile
  end
end
