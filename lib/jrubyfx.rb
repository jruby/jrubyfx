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

if RUBY_VERSION.include? "1.8" or !JRUBY_VERSION
  puts "JRubyFX requires JRuby to be in 1.9 mode"
  exit -2
end
if Gem::Version.new(JRUBY_VERSION) < Gem::Version.new("1.7.4")
  puts "Warning: JRuby 1.7.3 and prior have bugs that can cause strange errors. Do not submit any bug reports. Please use JRuby 1.7.4 or later."
end

require 'java' # for java_import
require 'jruby/core_ext' # for the become_java!

unless File.size? "#{File.dirname(__FILE__)}/jrubyfx/imports.rb"
  puts "Please run `rake reflect` to generate the imports"
  exit -1
end
# JRubyFX includes
require_relative 'jrubyfx/imports'
require_relative 'jrubyfx/module'
require_relative 'jrubyfx/dsl'
require_relative 'jrubyfx/dsl_control'
JRubyFX::DSL.load_dsl # load it after we require the dsl package to not loop around
require_relative 'jrubyfx/application'
require_relative 'jrubyfx/controller'
require_relative 'jrubyfx/java_fx_impl'
