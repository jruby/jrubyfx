#
# Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
#

# Modified by Hiroshi Nakamura <nahi@ruby-lang.org>
require 'java'
require 'jfxrt'
require 'jrubyfx'

import 'javafx.stage.Stage'
import 'javafx.scene.Scene'
import 'javafx.scene.paint.Color'
import 'javafx.scene.shape.Rectangle'
import 'javafx.animation.Timeline'
import 'javafx.animation.KeyValue'
import 'javafx.animation.KeyFrame'
import 'javafx.event.EventHandler'
import 'javafx.util.Duration'
import 'javafx.scene.shape.Path'
import 'javafx.scene.shape.Line'
import 'javafx.scene.shape.LineTo'
import 'javafx.scene.shape.MoveTo'
import 'javafx.scene.shape.ArcTo'
import 'javafx.scene.Group'
import 'javafx.scene.shape.Circle'
import 'javafx.scene.paint.Stop'
import 'javafx.scene.paint.RadialGradient'
import 'javafx.scene.paint.CycleMethod'
import 'java.util.Calendar'
import 'javafx.scene.transform.Rotate'
import 'java.lang.System'

# TODO: temporary manual bootstrap
java_import 'org.jruby.ext.jrubyfx.JRubyFX'


class AnalogClock

  $hours
  $minutes
  $seconds
  $time
  $minute_hand
  $hour_hand
  $second_hand

  
  $init_counter = 0

  $instance

  #Create stage, scene and fill it with background and clock itself
  def start(stage)
    $instance = self
 
    stage.width = 245
    stage.height = 265
    stage.title = 'Analog Clock (Ruby)'
    stage.resizable = false
 
    clock = create_content

    group = Group.new
    group.children << clock
 
    stage.scene = Scene.new(group)
 
    stage.show;
  end
 
  #Return group with content
  def create_content
 
    #Initialize values
    width = 240.0
    height = 240.0
    radius = width/3.0
    center_x = width/2.0
    center_y = height/2.0

    #Create gradients
    stop1 = Stop.new(0.9, Color::SILVER)
    stop2 = Stop.new(1.0, Color::BLACK)
    stops = Array.new(2)
    stops << stop1 << stop2
    base_circle_gradient = RadialGradient.new(0, 0, 0, 0,
        radius + 20, false, CycleMethod::NO_CYCLE, stops)
    stop1 = Stop.new(0.0, Color::WHITE)
    stop2 = Stop.new(1.0, Color::CADETBLUE)
    stops = Array.new(2)
    stops << stop1 << stop2
    upper_circle_gradient = RadialGradient.new(0, 0, 0, 0,
        90, false, CycleMethod::NO_CYCLE, stops)
    #Create gradients
    
    #Create a group of all clock components
    group = Group.new
    group.translateX = center_x
    group.translateY = center_y

    circle = Circle.new
    circle.radius = radius + 20.0
    circle.fill = base_circle_gradient
    group.children << circle
 
    circle = Circle.new
    circle.radius = radius + 10.0
    circle.fill = upper_circle_gradient
    circle.stroke = Color::BLACK
    group.children << circle
 
    #Create hour marks 
    for i in 0..11
 
      pom_y = -Math.cos(Math::PI/6.0*i)*radius
      pom_x = Math.sqrt(radius*radius-pom_y*pom_y)
      if i > 5 then
        pom_x = - pom_x;
      end
 
      if i % 3 == 0 then
        dot_radius = 4.0
      else
        dot_radius = 2.0
      end
 
      circle = Circle.new
      circle.fill = Color::BLACK
      circle.translateY = pom_y
      circle.translateX = pom_x
      circle.radius = dot_radius
 
      group.children << circle
 
    end
 

    circle = Circle.new
    circle.fill = Color::BLACK
    circle.radius = 5
    group.children << circle
 
    $minute_hand = Path.new
    $minute_hand.fill = Color::BLACK
    elem1 = MoveTo.new(4, -4)
    elem2 = ArcTo.new(-1, -1, 0, -4, -4, false, false)
    elem3 = LineTo.new(0, -radius)
    $minute_hand.elements << elem1 << elem2 << elem3
    group.children << $minute_hand
 
    $hour_hand = Path.new
    $hour_hand.fill = Color::BLACK
    elem1 = MoveTo.new(4, -4)
    elem2 = ArcTo.new(-1, -1, 0, -4, -4, false, false)
    elem3 = LineTo.new(0, -radius/4*3)
    $hour_hand.elements << elem1 << elem2 << elem3
    group.children << $hour_hand
 
    $second_hand = Line.new
    $second_hand.endY = -radius - 3
    $second_hand.strokeWidth = 2
    $second_hand.stroke = Color::RED
    group.children << $second_hand
 
    #Run the clock
    play

    return group
  end
 
  #Performed every second
  def refresh_time
    $seconds = ($seconds + 1) % 60;
    if $seconds == 0 then
        $minutes = ($minutes + 1) % 60;
        if $minutes == 0 then
            $hours = ($hours + 1) % 12;
        end
        $minute_hand.transforms[0].angle = $minutes*6
        $hour_hand.transforms[0].angle = $hours*30+$minutes*0.5
    end
    $second_hand.transforms[0].angle = $seconds*6
 
    #Hands are in the beginning drawn in with wrong angles, so this should move them right
    if $init_counter < 2 then
      $minute_hand.transforms[0].angle = $minutes*6
      $hour_hand.transforms[0].angle = $hours*30+$minutes*0.5
      $init_counter += 1
    end
  end
 
  #Set the actual time
  def init_clock
    calendar = Calendar.instance
    $hours = calendar.get(Calendar::HOUR)
    $minutes = calendar.get(Calendar::MINUTE)
    $seconds = calendar.get(Calendar::SECOND)
     
    $second_hand.transforms << Rotate.new
    $minute_hand.transforms << Rotate.new
    $hour_hand.transforms << Rotate.new
 
    $hour_hand.transforms[0].angle = $hours*30+$minutes*0.5
    $minute_hand.transforms[0].angle = $minutes*6
    $hour_hand.transforms[0].angle = $seconds*6
  end
 
  #Initialize, schedule and run the clock
  def play
    init_clock
    refresh_time #first refresh
 
    refresh_time_handler = EventHandler.new
    def refresh_time_handler.handle(event)
      $instance.refresh_time()
    end
 
    #schedule
    $time = Timeline.new
    $time.cycleCount = Timeline::INDEFINITE
    $time.keyFrames << KeyFrame.new(Duration.millis(1000), refresh_time_handler)
 
    sleep(1 - (System.currentTimeMillis()%1000)/1000.0)
 
    #Run the schedule
    $time.play()
 
  end
 
end
 
JRubyFX.start(AnalogClock.new)
