=begin
JRubyFX - Write JavaFX and FXML in Ruby
Copyright (C) 2013 The JRubyFX Team

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end
require 'jrubyfx/dsl'

# JRubyFX DSL extensions for JavaFX animation Timelines
class Java::javafx::animation::Timeline
  java_import Java::javafx.animation.KeyFrame

  extend JRubyFX::Utils::CommonConverters

  # call-seq:
  #   animate myProperty, from_duration => to_duration, start_value => next_value
  #   animate myProperty, from_duration => [with_duration, ..., to_duration], start_value => [next_value, ...]
  #
  # Animates a given JavaFX property over the given duration, using the given values
  # as keyFrames
  #
  # === Examples
  #   animate translateXProperty, 0.sec => [100.ms, 1.sec], 0 => [500, 200]
  #   animate translateYProperty, 0.sec => 1.sec, 0 => 200
  #
  def animate(prop, args)
    time = []
    values = []
    # detect our time
    args.each do |key, value|
      if key.is_a? Duration
        time << [key, value]
        time.flatten!
      else #assume values
        values << [key, value]
        values.flatten!
      end
    end
    # add the keyframes
    [time.length, values.length].min.times do |i|
      key_frame(time[i], key_value(prop, values[i]))
    end
  end

  converter_for :cycle_count, [map_converter(indefinite: Java::javafx::animation::Timeline::INDEFINITE)]
end
