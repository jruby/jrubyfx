# Original version is here: https://gist.github.com/1358093

require 'jrubyfx'

class AnalogClock
  include JRubyFX

  def start(stage)
    @stage = stage
    stage.layout(title: 'Analog Clock', width: 245, height: 265) do
      base_radius = (width - 5) / 3.0

      scene do
        group do
          circle(radius: base_radius + 20.0) do  # outer circle
            fill radial_gradient(0, 0, 0, 0, radius, false, :no_cycle,
                                 [stop(0.9, :silver), stop(1.0, :black)])
          end
          circle(radius: base_radius + 10.0, stroke: black) do  # inner circle
            fill radial_gradient(0, 0, 0, 0, 90, false, :no_cycle,
                                 [stop(0.0, :white), stop(1.0, :cadetblue)])
          end

          0.upto(11) do |i|
            y = -Math.cos(Math::PI/6.0 * i) * base_radius
            x = Math.sqrt(base_radius * base_radius - y * y) * (i > 5 ? -1 : 1)
            size = i % 3 == 0 ? 4 : 2
            circle(x, y, size, Color::BLACK)
          end

          circle(5, :black) # Hmmm sym to color automatically?

          # FIXME: arc_to has two default to false here
          name[:minutes] = path(fill: black) do
            elements.concat(move_to(4, -4), arc_to(-1, -1, 0, -4, -4), 
                            line_to(0, -radius))
            transforms << rotate
          end

          name[:hours] = path(fill: black) do
            elements.concat(move_to(4, -4), arc_to(-1, -1, 0, -4, -4),
                            line_to(0, -radius/4*3))
            transforms << rotate
          end

          name[:seconds] = line(end_y: -radius - 3, stroke_width: 2) do |sh|
            stroke :red
            transforms << Rotate.new
          end
        end
      end
    end
    play
    stage.show
  end
 
  def refresh_time
    t = Time.now
    @stage[:seconds].transforms[0].angle = t.sec * 6
    @stage[:minutes].transforms[0].angle = t.min * 6
    @state[:hours].transforms[0].angle = t.hour * 30 + t.min * 0.5
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
