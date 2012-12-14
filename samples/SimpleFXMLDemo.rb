#!/usr/bin/env jruby
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

# Require JRubyFXML library so we can get FXMLApplication and FXMLController
require 'jrubyfxml'

# Inherit from FXMLApplication to create our Application
class SimpleFXMLApplication < FXMLApplication
  # we must override start to get a stage on application initialization
  def start(stage)
    # assign the title, width, and height
    stage.title = "Simple JavaFX FXML App in pure Ruby"
    stage.width = 620
    stage.height = 480
    
    # create a new instance of our controller. Note that you MUST use new_java
    # to ensure that it is really a java object. new_java is specific to 
    # the FXMLController class
    ctrlr = SimpleFXMLController.new_java
    
    # Load the FXML file. Hopefully in future versions you won't need this
    fxml = load_fxml("#{File.dirname(__FILE__)}/Sample.fxml", ctrlr)
    
    # Create a new Scene with our parsed FXML
    stage.scene = Scene.new(fxml)
    
    # Give our controller the scene also. THIS IS CRITICAL if you have fx:id
    # properties. Not setting this prevents the fx:id's from binding properly
    ctrlr.scene = stage.scene
    
    # finally, show our app
    stage.show
  end
end

# Inherit from FXMLController to create our controller for this FXML file.
# You will need one Controller per FXML file under normal conditions.
class SimpleFXMLController < FXMLController
  
  # Here we declare that AnchorPane is a fx:id in the file
  fx_id :AnchorPane
  
  # Initialize must have url and resources as it is actually an interface method
  def initialize(url = nil, resources = nil)
    if url == nil
      # ruby new
      puts "ruby new"
    else
      # Java interface call
      puts "initalized"
    end
  end
  
  # This is how events are defined in code.
  # This will be called from FXML by onAction="#click"
  on_action :click do 
    puts "Clicked Green"
  end
  
  on_action :clickbl do
    puts "Clicked Black"
    p @AnchorPane
  end
  
  # If you want to capture the ActionEvent object, just request it like this
  on_action :clickre do |arg|
    puts "Clicked Red"
    p arg
  end
end

# Launch our application!
SimpleFXMLApplication.launch
