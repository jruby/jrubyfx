# Original version is for GroovyFX by @kazuchika
# https://gist.github.com/1362259G

require 'jrubyfx'

class MovieApp
  include JRubyFX
  include JRubyFX::DSL

  def start(stage)
    source_url = 'http://www.mediacollege.com/video-gallery/testclips/20051210-w50s_56K.flv'
    transition = nil

    with(stage, title: 'MediaView Demo', :width => 640, :height => 380) do
      layout_scene do
        group do
          media_view(media_player(media(source_url), auto_play: true), :fit_width => 640, :fit_height => 380, id: 'view') do
            transition = parallel_transition(:node => self) do
              duration = Duration.millis(5000)
              rotate_transition(:duration => duration, :from_angle => 0, :to_angle => 360)
              fade_transition(:duration => duration, :from_value => 0.0, :to_value => 1.0)
              scale_transition(:duration => duration, :from_x => 0.0, :from_y => 0.0, :to_x => 1.0, :to_y => 1.0)
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

MovieApp.start
