require 'jrubyfx/utils/common_converters'

# JRubyFX DSL extensions for JavaFX Circles
class Java::javafx::scene::shape::Circle
  class << self
    extend JRubyFX::Utils::CommonConverters

    converter_for :new, [], [:none], [:none, :color], [:none, :none, :none], [:none, :none, :none, :color]
  end
end
