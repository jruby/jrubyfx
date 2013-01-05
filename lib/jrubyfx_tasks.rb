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

module JRubyFX
  # This module contains utilities to jarify an app, and can be used in a rakefile or a running app.
  module Tasks
    extend Rake::DSL
    # Base URL of JRuby-complete.jar download location
    BASE_URL='http://repository.codehaus.org/org/jruby/jruby-complete'

    ##
    # Downloads the jruby-complete jar file for `jruby_version` and save in 
    # ~/.jruby-jar/jruby-complete.jar unless it already exits. If the jar is 
    # corrupt or an older version, set force to true to delete and re-download
    def download_jruby(jruby_version, force=false)
      dist = "#{ENV['HOME']}/.jruby-jar"
      unless force || (File.exists?("#{dist}/jruby-complete.jar") && File.size("#{dist}/jruby-complete.jar") > 0)
        mkdir_p dist
        base_dir = Dir.pwd
        cd dist
        puts "JRuby complete jar not found. Downloading... (May take awhile)"
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
    def jarify_jrubyfx(src="src/*" ,main_script=nil, target="target", output_jar="jrubyfx-app.jar", jar="jar")
      if target_was_nil = target == nil
        target = Dir.mktmpdir("jrubyfx")
        final_jar = output_jar
        output_jar = File.basename output_jar
      end

      mkdir_p target

      #copy jruby jar file in, along with script and our rb files
      cp "#{ENV['HOME']}/.jruby-jar/jruby-complete.jar", "#{target}/#{output_jar}"

      #copy source in
      FileList[src].each do |iv_srv|
        cp iv_srv, "#{target}/#{File.basename(iv_srv)}" if main_script == nil || main_script != iv_srv
      end
      cp main_script, "#{target}/jar-bootstrap.rb" unless main_script == nil

      unless File.exists? "#{target}/jar-bootstrap.rb"
        puts "@"*79
        puts "@#{"!!!WARNING!!!".center(79-2)}@"
        puts "@#{"jar-bootstrap.rb NOT FOUND!".center(79-2)}@"
        puts "@#{"Did you set main_src= or have jar-bootstrap in src= ?".center(79-2)}@"
        puts "@"*79
      end

      #copy our libs in
      FileList["#{File.dirname(__FILE__)}/*"].each do |librb|
        cp_r librb, target
      end

      # edit the jar
      base_dir = Dir.pwd
      cd target
      sh "#{jar} ufe '#{output_jar}' org.jruby.JarBootstrapMain *"
      chmod 0775, output_jar
      cd base_dir

      if target_was_nil
        mv "#{target}/#{output_jar}", final_jar
        rm_rf target
      end
    end

    private
    def download(version_string) #:nodoc:
      File.open("jruby-complete.jar","wb") do |f|
        f.write(open("#{BASE_URL}/#{version_string}/jruby-complete-#{version_string}.jar").read)
      end
    end

    module_function :jarify_jrubyfx
    module_function :download_jruby
    module_function :download
  end
end
