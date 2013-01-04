require 'jrubyfx/utils/common_converters'

# JRubyFX DSL extensions for JavaFX Labeled
class Java::javafx::scene::control::Labeled
  extend JRubyFX::Utils::CommonConverters

  converter_for :text_fill, [:color]
end
