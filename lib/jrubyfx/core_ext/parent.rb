require 'jrubyfx/dsl'

# JRubyFX DSL extensions for all JavaFX Parents
class Java::javafx::scene::Parent
  java_import Java::javafx.scene.Node

  include JRubyFX::DSL
  
  include_add
  include_method_missing Node
  
end
