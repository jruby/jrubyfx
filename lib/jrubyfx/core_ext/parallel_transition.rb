require 'jrubyfx/dsl'

# JRubyFX DSL extensions for JavaFX ParallelTransition
class Java::javafx::animation::ParallelTransition
  java_import Java::javafx.animation.Animation

  include JRubyFX::DSL
  
  include_add
  include_method_missing Animation
  
end
