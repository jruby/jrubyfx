require 'jrubyfx/dsl'

# JRubyFX DSL extensions for JavaFX Nodes
class Java::javafx::scene::Node
  include JRubyFX::DSL

  ##
  # Add rotate to transform (manually added ebcause there is a getRotate
  # on Node already.  Use get_rotate to get property
  def rotate(*args)
    transforms << build(Rotate, *args)
  end
end
