require 'jrubyfx/dsl'

# JRubyFX DSL extensions for JavaFX Nodes
class Java::javafx::scene::Node
  include JRubyFX::DSL

  include_rotate
end
