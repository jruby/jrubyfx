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

if !JRUBY_VERSION
  puts "JRubyFX requires JRuby"
  exit -2
end
if Gem::Version.new(JRUBY_VERSION) < Gem::Version.new("9.3.4.0")
  puts "JRubyFX 2.0 requires JRuby 9.3.4.0 or later. Use JRubyFX 1.x for earlier versions."
  exit -2
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
require_relative 'jrubyfx/fxml_helper'
require_relative 'jrubyfx/application'
require_relative 'jrubyfx/controller'
