require 'jrubyfx/utils/common_converters'

class Java::javafx::scene::paint::RadialGradient
  class << self
    java_import Java::javafx.scene.paint.CycleMethod
    extend JRubyFX::Utils::CommonConverters

    cycle_method = map_converter(no_cycle: CycleMethod::NO_CYCLE,
                                 reflect: CycleMethod::REFLECT,
                                 repeat: CycleMethod::REPEAT)

    converter_for :new, [:none, :none, :none, :none, :none, :none, cycle_method, :none]
  end
end
