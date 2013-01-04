# JRubyFX DSL extensions for JavaFX Paths
class Java::javafx::scene::shape::Path
  java_import Java::javafx.scene.shape.PathElement
  java_import Java::javafx.scene.transform.Transform

  include JRubyFX::DSL

  include_add :elements

  include_rotate

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
