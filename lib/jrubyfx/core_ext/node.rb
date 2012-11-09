require 'jrubyfx/dsl'

class Java::javafx::scene::Node
  include JRubyFX::DSL

  ##
  # Add rotate to transform (manually added ebcause there is a getRotate
  # on Node already.  Use get_rotate to get property
  def rotate(*args)
    transforms << build(Rotate, *args)
  end
end
