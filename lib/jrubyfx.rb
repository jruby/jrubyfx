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
require 'java' # for java_import
require 'jruby/core_ext' # for the become_java!

# JRubyFX includes
require_relative 'jrubyfx/jfx_imports'
require_relative 'jrubyfx/fxml_module'
require_relative 'jrubyfx/dsl'
JRubyFX::DSL.load_dsl # load it after we require the dsl package to not loop around
require_relative 'jrubyfx/fxml_application'
require_relative 'jrubyfx/fxml_controller'
require_relative 'jrubyfx/java_fx_impl'
