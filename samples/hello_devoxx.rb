# Original version is here: http://www.slideshare.net/steveonjava/java-fx-20-a-developers-guide

require 'jrubyfx'

class HelloDevoxx
  include JRubyFX

  def start(stage)
    root = build(Group) {
      children << build(Text,
                        "Hello Devoxx",
                        x: 105,
                        y: 120,
                        font: Font.new(30))
    }
    with(stage,
         title: "Hello Devoxx",
         width: 400,
         height: 250,
         scene: build(Scene,
                      root,
                      fill: Color::BLUE)).show
  end
end

HelloDevoxx.start
