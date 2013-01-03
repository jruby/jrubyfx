# JRubyFX DSL extensions for JavaFX animation Timelines
class Java::javafx::animation::Timeline
  java_import Java::javafx.animation.KeyFrame

  include JRubyFX::DSL

  ##
  # Add to child list without need to ask for children
  def add(value)
    self.key_frames << value
  end

  include_method_missing KeyFrame
end
