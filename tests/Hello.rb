require 'jrubyfx'
fxml_root File.dirname(__FILE__)

class HelloWorldApp < JRubyFX::Application
	def start(stage)
		with(stage, title: "Hello World!", width: 800, height: 600) do
		  fxml HelloWorldController
		  show
		end
	end
end

class HelloWorldController
  include JRubyFX::Controller
  fxml "Hello.fxml"

	def say_clicked
		@hello_label.text = "You clicked me!"
	end
end

HelloWorldApp.launch
