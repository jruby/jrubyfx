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

# JRubyFX DSL extensions for JavaFX color stops
class Java::javafx::scene::transform::Rotate
  extend JRubyFX::Utils::CommonConverters
  
  @@axis_conversions = map_converter(x_axis: X_AXIS,
                                   y_axis: Y_AXIS,
                                   z_axis: Z_AXIS,
                                   x: X_AXIS,
                                   y: Y_AXIS,
                                   z: Z_AXIS)

  converter_for :axis, [@@axis_conversions]

  class << self
    extend JRubyFX::Utils::CommonConverters

    converter_for :new, [], [:none], [:none, @axis_conversions], [:none, :none, :none],
                  [:none, :none, :none, :none], [:none, :none, :none, :none, @axis_conversions]
  end

end
