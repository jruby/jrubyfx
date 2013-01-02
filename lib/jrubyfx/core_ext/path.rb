# JRubyFX DSL extensions for JavaFX Paths
class Java::javafx::scene::shape::Path
  java_import Java::javafx.scene.shape.PathElement
  java_import Java::javafx.scene.transform.Transform

  ##
  # Add to child list without need to ask for children
  def add(value)
    self.elements << value
  end

  ##
  # Add rotate to transform (manually added ebcause there is a getRotate
  # on Path already.  Use get_rotate to get property
  def rotate(*args)
    transforms << build(Rotate, *args)
  end

  ##
  # This will defer to node to construct proper object, but will
  # optionally add paths primary child automatically if it is a
  # PathElement.
  def method_missing(name, *args, &block)
    super.tap do |obj|
      if obj.kind_of? PathElement
        add(obj)
      elsif obj.kind_of? Transform
        transforms << obj
      end
    end
  end
end
