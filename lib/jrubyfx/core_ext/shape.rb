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
