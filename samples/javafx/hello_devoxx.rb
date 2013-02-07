#!/usr/bin/env jruby
# Original version is here: http://www.slideshare.net/steveonjava/java-fx-20-a-developers-guide

require 'jrubyfx'

class HelloDevoxx < JRubyFX::Application

  def start(stage)
    with(stage, title: "Hello Devoxx", x: 105, y: 140) do
      layout_scene(500, 250, :black) do
        hbox(padding: 60) do
          text('JRuby', font: font('sanserif', 80)) do
            fill linear_gradient(0, 0, 0, 1, true, :no_cycle, [stop(0, :pale_green), stop(1, :sea_green)])
          end
          text('FX', font: font('sanserif', 80)) do
            fill linear_gradient(0, 0, 0, 1, true, :no_cycle, [stop(0, :cyan), stop(1, :dodger_blue)])
            effect drop_shadow(color: :dodger_blue, radius: 25, spread: 0.25)
          end
        end
      end
      show
    end
  end
end

HelloDevoxx.launch
