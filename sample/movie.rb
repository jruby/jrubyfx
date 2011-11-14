# Original version is for GroovyFX by @kazuchika
# https://gist.github.com/1362259G

require File.expand_path('./utils', File.dirname(__FILE__))

java_import 'javafx.animation.FadeTransition'
java_import 'javafx.animation.ParallelTransition'
java_import 'javafx.animation.RotateTransition'
java_import 'javafx.animation.ScaleTransition'
java_import 'javafx.scene.Group'
java_import 'javafx.scene.Scene'
java_import 'javafx.scene.effect.SepiaTone'
java_import 'javafx.scene.effect.GaussianBlur'
java_import 'javafx.scene.media.MediaView'
java_import 'javafx.scene.media.MediaPlayer'
java_import 'javafx.scene.media.Media'
java_import 'javafx.scene.paint.Color'
java_import 'javafx.stage.Stage'
java_import 'javafx.util.Duration'

class MovieApp
  include Utils

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

JRubyFX.start(MovieApp.new)
