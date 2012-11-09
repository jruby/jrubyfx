class Java::javafx::scene::Group
  java_import Java::javafx.scene.shape.Shape

  ##
  # Add to child list without need to ask for children
  def add(value)
    self.get_children << value
  end

  ##
  # This will defer to node to construct proper object, but will
  # optionally add paths primary child automatically if it is a
  # PathElement.
  def method_missing(name, *args, &block)
    super.tap do |obj|
      add(obj) if obj.kind_of? Shape
    end
  end
end
