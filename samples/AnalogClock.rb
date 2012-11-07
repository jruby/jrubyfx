# Original version is here: https://gist.github.com/1358093

require 'jrubyfx'

class AnalogClock
  include JRubyFX

  def start(stage)
    stage.initStyle StageStyle::TRANSPARENT
    stage.tap do |s|
      s.title, s.width, s.height = 'Analog Clock (Ruby)', 245, 265
      s.resizable = false
      group = Group.new.tap {|g| g.children << create_content }
      s.scene = Scene.new(group).tap do |sc|
        sc.fill = nil # Completes transparency
        sc.set_on_key_pressed { |e| java.lang.System.exit(0) }
      end
      s.show
    end
  end

  def create_content
    width, height = 240.0, 240.0
    radius = width / 3.0

    #Create a group of all clock components
    group = Group.new
    group.translateX = width / 2.0
    group.translateY = height / 2.0
    group.children << Circle.new.tap do |c| # outer circle
      c.radius = radius + 20.0
      c.fill = RadialGradient.new(0, 0, 0, 0, radius + 20, false, CycleMethod::NO_CYCLE, [Stop.new(0.9, Color::SILVER), Stop.new(1.0, Color::BLACK)])
    end
    group.children << Circle.new.tap do |c| # inner circle
      c.stroke = Color::BLACK
      c.radius = radius + 10.0
      c.fill = RadialGradient.new(0, 0, 0, 0, 90, false, CycleMethod::NO_CYCLE, [Stop.new(0.0, Color::WHITE), Stop.new(1.0, Color::CADETBLUE)])
    end

    0.upto(11) do |i|
      y = -Math.cos(Math::PI/6.0 * i) * radius
      x = Math.sqrt(radius * radius - y * y) * (i > 5 ? -1 : 1)
      size = i % 3 == 0 ? 4 : 2
      group.children << Circle.new(x, y, size, Color::BLACK)
    end
 
    group.children << Circle.new(5, Color::BLACK)
 
    @minute_hand = Path.new.tap do |mh|
      mh.fill = Color::BLACK
      mh.elements << MoveTo.new(4, -4)
      mh.elements << ArcTo.new(-1, -1, 0, -4, -4, false, false)
      mh.elements << LineTo.new(0, -radius)
      mh.transforms << Rotate.new
    end
 
    @hour_hand = Path.new.tap do |hh|
      hh.fill = Color::BLACK
      hh.elements << MoveTo.new(4, -4)
      hh.elements << ArcTo.new(-1, -1, 0, -4, -4, false, false)
      hh.elements << LineTo.new(0, -radius/4*3)
      hh.transforms << Rotate.new
    end
 
    @second_hand = Line.new.tap do |sh|
      sh.stroke = Color::RED
      sh.endY = -radius - 3
      sh.strokeWidth = 2
      sh.transforms << Rotate.new
    end

    group.children << @hour_hand << @minute_hand << @second_hand
 
    play

    group
  end
 
  def refresh_time
    t = Time.now
    @second_hand.transforms[0].angle = t.sec * 6
    @minute_hand.transforms[0].angle = t.min * 6
    @hour_hand.transforms[0].angle = t.hour * 30 + t.min * 0.5
  end
 
  def play
    refresh_time # Initially set hands to proper locs
    handler = EventHandler.impl { |n, e| refresh_time }
    time = Timeline.new
    time.cycleCount = Timeline::INDEFINITE
    time.keyFrames << KeyFrame.new(Duration.millis(1000), handler)
    time.play
  end
end
 
AnalogClock.start
