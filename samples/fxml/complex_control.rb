require 'jrubyfx'

class ComplexControl < Java::javafx::scene::layout::BorderPane
  include JRubyFX::ControllerBase
  custom_fxml_control

  def initialize(text)
    @textBox = textBox
    @label = lookup("#label")
    @label.text = text
  end

  def text
    @textBox.text
  end
  def text=(v)
    @textBox.text = v
  end
end