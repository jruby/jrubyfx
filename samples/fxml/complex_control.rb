require 'jrubyfx'

class ComplexControl < Java::javafx::scene::layout::BorderPane
  include JRubyFX::Controller
  #default one, also guessable from class name
  fxml "ComplexControl.fxml"

  #optional
  def java_ctor(ctor, initialize_args)
    ctor.call() # any arguments to BorderPane constructor go here
  end

  def initialize(text)
    #force override
    load_fxml "ComplexControl.fxml"

    @label.text = text
  end

  def text
    @textBox.text
  end
  def text=(v)
    @textBox.text = v
  end
  
  # This is an event handler
  def announce_it # optional: add argument e
    puts "Text box contains: #{text}"
    self.text = ""
  end
end