=begin
JRubyFX - Write JavaFX and FXML in Ruby
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
require 'rubygems'
require 'rubygems/installer'
require 'rubygems/package_task'
require 'rdoc/task'
require_relative 'lib/jrubyfx_tasks'
require_relative 'lib/jrubyfx/version'
task :default => [:build, :run]

jar = ENV['jar'] || "jar"
target = ENV['target'] || "target"
output_jar = ENV['output_jar'] || "rubyfx-app.jar"
main_script = ENV['main_script'] || nil
src = ENV['src'] || 'src/*'
jruby_version = ENV['jruby_version'] || JRUBY_VERSION || "1.7.1" #if they want speedy raking, use the default so they can use MRI or other rubies

base_dir = File.dirname(__FILE__)
cd base_dir unless Dir.pwd == base_dir
main_script = nil if main_script == "nil"

desc "Clean all build artifacts except jruby-complete.jar"
task :clean do
  rm_rf target if File.exists? target
  rm_rf "pkg" if File.exists? "pkg"
  rm_rf "doc" if File.exists? "doc"
end

desc "Clean all build artifacts INCLUDING jruby-complete.jar"
task :clean_jruby => :clean do
  rm_rf "#{ENV['HOME']}/.jruby-jar"
end

desc "Run a script without installing the gem"
task :run do
  ruby "-I lib '#{main_script||'samples/fxml/Demo.rb'}'"
end

load 'jrubyfx.gemspec'
Gem::PackageTask.new($spec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end

desc "Build and install the gem"
task :install => :gem do
  Gem::Installer.new("pkg/jrubyfx-#{JRubyFX::VERSION}-java.gem").install
end

task :download_jruby_jar do
  JRubyFX::Tasks::download_jruby(jruby_version)
end

desc "Create a full jar with embedded JRuby and given script (via main_script and src ENV var)"
task :jar => [:clean, :download_jruby_jar] do
  JRubyFX::Tasks::jarify_jrubyfx(src, main_script, target, output_jar, jar)
end

desc "Create a full jar and run it"
task :run_jar => :jar do
  sh "java -jar #{target}/#{output_jar}"
end

RDoc::Task.new do |rdoc|
  files = ['lib'] # FIXME: readme and markdown
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.md"
  rdoc.title = "JRubyFX Docs"
  rdoc.rdoc_dir = 'doc/'
end
