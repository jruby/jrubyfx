# You need to build SVGLoader.jar first.
#
# 1) git clone https://github.com/skrb/SVGLoader.git
# 2) cd SVGLoader
# 3) mkdir lib; vi lib/nblibraries.properties
#   (ex.)
#   platforms.JDK_1.7.home=C:/Program Files/Java/jdk1.7.0_02/
#   javafx.runtime=C:/Program Files/Oracle/JavaFX Runtime 2.0/
#   javafx.sdk=C:/Program Files/Oracle/JavaFX 2.0 SDK/
# 4) ant jar -> dist/SVGLoader.jar
#
# duke.svg is copied from: https://github.com/skrb/SVGLoader/tree/master/src

require_relative('utils')
require 'SVGLoader.jar'

java_import 'javafx.animation.KeyFrame'
java_import 'javafx.animation.KeyValue'
java_import 'javafx.animation.Timeline'
java_import 'javafx.scene.Group'
java_import 'javafx.scene.Scene'
java_import 'javafx.util.Duration'

java_import 'net.javainthebox.caraibe.svg.SVGLoader'

class SVGLoaderApp
  include Utils

  def start(stage)
    root = build(Group) {
      children <<
        with(SVGLoader.load("/duke.svg").root) {
          kf1 = KeyFrame.new(Duration::ZERO, KeyValue.new(translateXProperty, 0))
          kf2 = KeyFrame.new(Duration.millis(1000), KeyValue.new(translateXProperty, 100))
          build(Timeline, cycle_count: Timeline::INDEFINITE, auto_reverse: true) {
            key_frames << kf1 << kf2
          }.play
        }
    }
    with(stage,
         title: 'SVGLoader sample',
         scene: build(Scene, root)).show
  end
end

JRubyFX.start(SVGLoaderApp.new)
