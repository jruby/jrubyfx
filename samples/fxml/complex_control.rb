require 'jrubyfx'

class ComplexControl < Java::javafx::scene::layout::BorderPane
  include JRubyFX::Controller
  #default one, also guessable from class name
  fxml_root "ComplexControl.fxml"

  #optional
  def java_ctor(ctor, initialize_args)
    ctor.call() # any arguments to BorderPane constructor go here
  end

  def initialize(text)
    #force override
    load_fxml_root "ComplexControl.fxml"

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