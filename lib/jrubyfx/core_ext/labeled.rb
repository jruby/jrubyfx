require 'jrubyfx/utils/common_converters'

class Java::javafx::scene::control::Labeled
  extend JRubyFX::Utils::CommonConverters

  converter_for :text_fill, [:color]
end
