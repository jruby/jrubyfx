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

# JRubyFX DSL extensions for JavaFX Duration
class Numeric
  # defines #ms, #sec, etc to create a JavaFX duration object of respective type
  {:ms => :millis, :sec => :seconds, :min => :minutes,
    :hrs => :hours, :hr => :hours}.each do |rname, jname|
    self.instance_eval do
      define_method rname do
        Java.javafx.util.Duration.method(jname).call(self)
      end
    end
  end
end