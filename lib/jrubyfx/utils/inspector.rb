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
module JRubyFX::Utils::Inspector

  class << self
    def included(base)
      base.extend ClassMethods
    end
  end

  module ClassMethods
    def inspect_properties props = {}
      @inspect_properties = props
    end
  end

  def inspect
    props = ["#{self.class}:#{'0x%08x' % object_id}"]
    props += (self.class.instance_variable_get('@inspect_properties')||discover_properties).
      map do |key,val|
        if val.is_a? Array
          values = val.dup
          format = values.shift
          values.map! {|v|send v}
          "#{key}:#{sprintf format, *values}"
        else
          "#{key}:#{send val}"
        end
      end
    "#<#{props.join ' '}>"
  end

private

  # Use reflection to discover properties
  def discover_properties
    props = {}
    (java_class.java_instance_methods - java_class.superclass.java_instance_methods).
      select {|m|m.return_type and m.return_type.interfaces.include? Java::JavafxBeansProperty::Property.java_class and not m.name =~ /^impl_/}.
      map    {|m|send(m.name).getName}.
      each   {|p|props.merge! p => p}
    self.class.instance_variable_set '@inspect_properties', props
  end

end
