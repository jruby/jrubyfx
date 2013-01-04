require 'jrubyfx/dsl'

# JRubyFX DSL extensions for JavaFX Scenes
class Java::javafx::scene::Scene
  include JRubyFX::DSL

  class << self
    extend JRubyFX::Utils::CommonConverters

    converter_for :new, [:none], [:none, :color], [:none, :none, :none],
       [:none, :none, :none, :color]
  end
end
