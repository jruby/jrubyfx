# encoding: utf-8

require 'jrubyfx'
fxml_root File.dirname(__FILE__)

class App < JRubyFX::Application

  def start(stage)
    stage.fxml MainWindowController
    stage.show
  end

end

class MainWindowController
  include JRubyFX::Controller
  fxml "toggle_button.fxml"

  def initialize *args
    @button.disable_property.bind @text.text_property.is_equal_to('')
    super
  end

  def on_button_clicked
    puts @text.text
  end

end

App.launch
