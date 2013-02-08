#!/usr/bin/env jruby
# Original version is for GroovyFX by @kazuchika
# https://gist.github.com/1362259G

require 'jrubyfx'

class MovieApp < JRubyFX::Application
  include JRubyFX::DSL

  def start(stage)
    source_url = 'http://www.mediacollege.com/video-gallery/testclips/20051210-w50s_56K.flv'
    transition = nil

    with(stage, title: 'MediaView Demo', :width => 640, :height => 380) do
      layout_scene do
        group do
          media_view(media_player(media(source_url), auto_play: true), :fit_width => 640, :fit_height => 380, id: 'view') do
            transition = parallel_transition(:node => self) do
              rotate_transition(duration: 5.sec, angle: {0 => 360})
              fade_transition(duration: 5.sec, value: {0.0 => 1.0})
              scale_transition(duration: 5.sec, x: {0.0 => 1.0}, y: {0.0 => 1.0})
            end
          end
        end
      end
    end.show
    stage.scene.set_on_key_released do |e|
      view = stage["#view"]
      puts "media key: #{e.text}"
      case e.text
      when "s"
        view.effect = view.effect ? nil : sepia_tone
      when "b"
        view.effect = view.effect ? nil : gaussian_blur(:radius => 30)
      when "t"
        transition.play_from_start
      end
    end
  end
end

MovieApp.launch
