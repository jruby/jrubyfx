class Java::javafx::scene::shape::Path
  java_import Java::javafx.scene.shape.PathElement

  ##
  # Add to child list without need to ask for children
  def add(value)
    self.elements << value
  end

  ##
  # This will defer to node to construct proper object, but will
  # optionally add paths primary child automatically if it is a
  # PathElement.
  def method_missing(name, *args, &block)
    super.tap do |obj|
      add(obj) if obj.kind_of? PathElement
    end
  end
end
