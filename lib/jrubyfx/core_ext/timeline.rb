# JRubyFX DSL extensions for JavaFX animation Timelines
class Java::javafx::animation::Timeline
  java_import Java::javafx.animation.KeyFrame

  include JRubyFX::DSL

  include_add :key_frames
  include_method_missing KeyFrame
end
