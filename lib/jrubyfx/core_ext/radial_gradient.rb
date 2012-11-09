require 'jrubyfx/utils/common_converters'

class Java::javafx::scene::paint::RadialGradient
  class << self
    java_import Java::javafx.scene.paint.CycleMethod
    extend JRubyFX::Utils::CommonConverters

    cycle_method = lambda do |value|
      case value
      when :no_cycle
        CycleMethod::NO_CYCLE
      when :reflect
        CycleMethod::REFLECT
      when :repeat
        CycleMethod::REPEAT
      else
        value
      end
    end

    converter_for :new, [:none, :none, :none, :none, :none, :none, cycle_method, :none]
  end
end
