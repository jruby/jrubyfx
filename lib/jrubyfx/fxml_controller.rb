=begin
JRubyFX - Write JavaFX and FXML in Ruby
Copyright (C) 2013 The JRubyFX Team

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end

require 'jrubyfx'
require_relative 'fxml_control'

# Inherit from this class for FXML controllers
module JRubyFX::Controller
  include JRubyFX::Control

  DEFAULT_SETTINGS = {
    width: -1,
    height: -1,
    fill: :white,
    depth_buffer: false,
    relative_to: nil,
    initialized: nil
  }

  # Controllers usually need access to the stage.
  attr_accessor :stage

  ##
  # Construction as a Java Class
  ##

  # Load given fxml file onto the given stage. `settings` is an optional hash of:
  # * :initialize => [array of arguments to pass to the initialize function]
  # * :width => Default width of the Scene
  # * :height => Default height of the Scene
  # * :fill => Fill color of the Scene's background
  # * :depth_buffer => JavaFX Scene DepthBuffer argument (look it up)
  # * :relative_to =>  filename search for fxml realtive to this file
  #
  # === Examples
  #
  #   controller = MyFXController.new "Demo.fxml", stage
  #
  # === Equivalent Java
  #   Parent root = FXMLLoader.load(getClass().getResource("Demo.fxml"));
  #   Scene scene = new Scene(root);
  #   stage.setScene(scene);
  #   controller = root.getController();

  def initialize_controller(opt, filename, stage, settings={})
    # Inherit from default settings with overloaded relative_to
    settings = DEFAULT_SETTINGS.merge({relative_to: self.class.instance_variable_get("@relative_to")}).merge settings

    # Set the stage so we can reference it if needed later
    self.stage = stage

    # load the FXML file
    root = Control.get_fxml_loader(filename, self, settings[:relative_to]).load

    # Unless the FXML root node is a scene, wrap that node in a scene
    if root.is_a? Scene
      scene = root
    else
      scene = Scene.new root, settings[:width], settings[:height], settings[:depth_buffer]
      scene.fill = settings[:fill]
    end

    # set the controller and stage scene
    @scene = stage.scene = scene

    finish_initialization *settings[:initialize].to_a
  end
end
