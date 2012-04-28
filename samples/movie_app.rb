# Original version is for GroovyFX by @kazuchika
# https://gist.github.com/1362259G

require 'jrubyfx'

class MovieApp
  include JRubyFX

  def start(stage)
    source_url = 'http://www.mediacollege.com/video-gallery/testclips/20051210-w50s_56K.flv'

    view = transition = nil

    root = build(Group) {
      player = build(MediaPlayer, build(Media, source_url), :auto_play => true)
      children << view = build(MediaView, player, :fit_width => 640, :fit_height => 380) {
        transition = build(ParallelTransition, :node => self) {
          duration = Duration.millis(5000)
          children << build(RotateTransition, :duration => duration, :from_angle => 0, :to_angle => 360)
          children << build(FadeTransition,   :duration => duration, :from_value => 0.0, :to_value => 1.0)
          children << build(ScaleTransition,  :duration => duration, :from_x => 0.0, :from_y => 0.0, :to_x => 1.0, :to_y => 1.0)
        }
      }
    }
    scene = build(Scene, root, :fill => Color::BLACK) {
      self.on_key_released = proc { |e|
        puts "media key: #{e.text}"
        case e.text
        when "s"
          view.effect = view.effect ? nil : build(SepiaTone)
        when "b"
          view.effect = view.effect ? nil : build(GaussianBlur, :radius => 30)
        when "t"
          transition.play_from_start
        end
      }
    }

    with(stage, :width => 640, :height => 380, :title => 'MediaView Demo', :scene => scene).show
  end
end

MovieApp.start
