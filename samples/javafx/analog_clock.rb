require 'jrubyfxml'

class AnalogClock < FXMLApplication

  def start(stage)
    @stage = stage
    with(stage, init_style: :transparent, width: 245, height: 265,
         title: 'Analog Clock (Ruby)', resizable: false) do
      layout_scene(fill: nil) do
        width, height = 240.0, 240.0
        radius = width / 3.0

        group(translate_x: width / 2.0, translate_y: height / 2.0) do
          circle(:radius => radius + 20.0) { # outer
            fill radial_gradient(0, 0, 0, 0, radius + 20, false, :no_cycle, [stop(0.9, :silver), stop(1, :black)])
          }
          circle(:radius => radius + 10.0) do  # inner
            fill radial_gradient(0, 0, 0, 0, 90, false, :no_cycle, [stop(0.0, :white), stop(1, :cadet_blue)])
          end

          0.upto(11) do |i|
            y = -Math.cos(Math::PI/6.0 * i) * radius
            x = Math.sqrt(radius * radius - y * y) * (i > 5 ? -1 : 1)
            size = i % 3 == 0 ? 4 : 2
            circle(x, y, size, :black)
          end
          
          circle(5, :black)
          
          path(fill: :black, id: 'minute') do
            move_to(4, -4)
            arc_to(-1, -1, 0, -4, -4, false, false)
            line_to(0, -radius)
            rotate
          end
          
          path(fill: :black, id: 'hour') do
            move_to(4, -4)
            arc_to(-1, -1, 0, -4, -4, false, false)
            line_to(0, -radius/4*3)
            rotate
          end
          
          line(stroke: :red, end_y: -radius-3, stroke_width: 2, id: 'second') do
            rotate
          end
        end
      end.set_on_key_pressed { |e| java.lang.System.exit(0) }
      show
    end
    play
  end

  def refresh_time
    t = Time.now
    @stage['#second'].transforms[0].angle = t.sec * 6
    @stage['#minute'].transforms[0].angle = t.min * 6
    @stage['#hour'].transforms[0].angle = t.hour * 30 + t.min * 0.5
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

AnalogClock.launch
