# JRubyFX DSL extensions for JavaFX animation Timelines
class Java::javafx::animation::Timeline
  java_import Java::javafx.animation.KeyFrame

  include JRubyFX::DSL

  ##
  # Add to child list without need to ask for children
  def add(value)
    self.key_frames << value
  end

  ##
  # This will defer to node to construct proper object, but will
  # optionally add paths primary child automatically if it is a
  # PathElement.
  def method_missing(name, *args, &block)
    super.tap do |obj|
      add(obj) if obj.kind_of? KeyFrame
    end
  end
end
