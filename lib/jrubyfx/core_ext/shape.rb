class Java::javafx::scene::shape::Shape
  extend JRubyFX::Utils::CommonConverters

  converter_for :fill, [:color]
  converter_for :stroke, [:color]
end
