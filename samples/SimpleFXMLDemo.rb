=begin
JRubyFXML - Write JavaFX and FXML in Ruby
Copyright (C) 2012 Patrick Plenefisch

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as 
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end

require 'jrubyfxml'

class SimpleFXMLDemo
  include JRubyFX

  def start(stage)
    stage.tap do |s|
      s.title, s.width, s.height = 'This is RUBY!!!!', 600,600
      ctrlr = TestController.new_java
      ctrlr.scene = s.scene = Scene.new(load_fxml "#{File.dirname(__FILE__)}/Sample.fxml", ctrlr)
      s.show
    end
  end

end

class TestController < FXMLController
  fxml_linked :AnchorPane
  def initialize(url = nil, resources = nil)
    if url == nil
      # ruby new
      puts "ruby new"
    else
      # Java interface call
      puts "initalized"
    end
  end
  
  fxml_event :click do 
    puts "Clicked Green"
  end
  
  fxml_event :clickbl do
    puts "Clicked Black"
    p @AnchorPane
  end
  
  fxml_event :clickre do |arg|
    puts "Clicked Red"
    p arg
  end
end

SimpleFXMLDemo.start
