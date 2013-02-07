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
require 'jrubyfx/dsl'

# JRubyFX DSL extensions for JavaFX Pagination
class Java::javafx::scene::control::Pagination
  extend JRubyFX::Utils::CommonConverters

  indeterm_map = map_converter(indeterminate: INDETERMINATE)

  converter_for :page_count, [indeterm_map]
  converter_for :new, [], [indeterm_map], [indeterm_map, :none]

end
