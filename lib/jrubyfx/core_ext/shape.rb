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
# JRubyFX DSL extensions for JavaFX Shapes
class Java::javafx::scene::shape::Shape
  extend JRubyFX::Utils::CommonConverters

  java_import Java::javafx.scene.shape.StrokeLineCap
  java_import Java::javafx.scene.shape.StrokeLineJoin
  java_import Java::javafx.scene.shape.StrokeType

  converter_for :fill, [:color]
  converter_for :fill=, [:color]
  converter_for :stroke, [:color]
  converter_for :stroke=, [:color]
  converter_for :stroke_line_cap, [map_converter(butt: StrokeLineCap::BUTT,
                                                round: StrokeLineCap::ROUND,
                                                square: StrokeLineCap::SQUARE)]
  converter_for :stroke_line_join, [map_converter(bevel: StrokeLineJoin::BEVEL,
                                                 miter: StrokeLineJoin::MITER,
                                                 round: StrokeLineJoin::ROUND)]
  converter_for :stroke_type, [map_converter(centered: StrokeType::CENTERED,
                                            inside: StrokeType::INSIDE,
                                            outside: StrokeType::OUTSIDE)]

  alias :fill :set_fill
end
