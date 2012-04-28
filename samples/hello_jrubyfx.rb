# Original version is here: http://www.oracle.com/technetwork/jp/ondemand/java/20110519-java-a-2-sato-400530-ja.pdf
# Modified by Hiroshi Nakamura <nahi@ruby-lang.org>

require 'jrubyfx'

class HelloJRubyFX
  include JRubyFX

  def start(stage)
    root = build(Group) {
      children <<
        build(Rectangle, x: 10, y: 40, width: 50, height: 50, fill: Color::RED) {
          kf1 = KeyFrame.new(Duration::ZERO, KeyValue.new(translateXProperty, 0))
          kf2 = KeyFrame.new(Duration.millis(1000), KeyValue.new(translateXProperty, 200))
          build(Timeline, cycle_count: Timeline::INDEFINITE, auto_reverse: true) {
            key_frames << kf1 << kf2
          }.play
        }
    }
    with(stage,
         width: 300, height: 200,
         title: 'Hello JRubyFX',
         scene: build(Scene, root, fill: Color::DARKBLUE)).show
  end
end

HelloJRubyFX.start
