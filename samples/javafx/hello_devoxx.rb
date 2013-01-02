#!/usr/bin/env jruby
# Original version is here: http://www.slideshare.net/steveonjava/java-fx-20-a-developers-guide

require 'jrubyfx'

class HelloDevoxx < FXApplication

  def start(stage)
    with(stage, title: "Hello Devoxx", x: 105, y: 140) do
      layout_scene(:blue) do
        group do
          text("Hello Devoxx", x: 105, y: 120, font: Font.new(30))
        end
      end
      show
    end
  end
end

HelloDevoxx.launch
