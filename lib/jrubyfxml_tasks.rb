=begin
JRubyFXML - Write JavaFX and FXML in Ruby
Copyright (C) 2012 Patrick Plenefisch

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as 
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end

# DO NOT INCLUDE ANY JRUBYFX CODE DIRECTLY!!! THIS IS A RAKEFILE EXTENSION!!!
require 'open-uri'
require 'rake'
require 'tmpdir'

module JRubyFXTasks 
  extend Rake::DSL
  BASE_URL='http://repository.codehaus.org/org/jruby/jruby-complete'
  

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

  def jarify_jrubyfxml(src="src/*" ,main_script=nil, target="target", output_jar="jrubyfx-app.jar", jar="jar")
    if target_was_nil = target == nil
      target = Dir.mktmpdir("jrubyfxml")
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

  def download(version_string)
    File.open("jruby-complete.jar","wb") do |f|
      f.write(open("#{BASE_URL}/#{version_string}/jruby-complete-#{version_string}.jar").read)
    end
  end
  
  module_function :jarify_jrubyfxml
  module_function :download_jruby
  module_function :download
end
