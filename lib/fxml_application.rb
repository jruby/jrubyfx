=begin
JRubyFXML - Write JavaFX and FXML in Ruby
Copyright (C) 2012 Patrick Plenefisch

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as 
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end

require 'jrubyfxml'

class FXMLApplication < Java.javafx.application.Application
  include JFXImports
  include JRubyFX::Utils::CommonUtils

  def self.in_jar?()
    $LOAD_PATH.inject(false) { |res,i| res || i.include?(".jar!/META-INF/jruby.home/lib/ruby/")}
  end

  def self.launch(*args)
    #call our custom launcher to avoid a java shim
    JavaFXImpl::Launcher.launch_app(self, *args)
  end
  
  def self.load_fxml(filename, ctrlr)
    fx = Java.javafx.fxml.FXMLLoader.new()
    fx.location = if in_jar?
      JRuby.runtime.jruby_class_loader.get_resource(filename)
    else
      Java.java.net.URL.new(
        Java.java.net.URL.new("file:"), "#{File.dirname($0)}/#{filename}") #hope the start file is relative!
    end
    fx.controller = ctrlr
    return fx.load()
  end

  ##
  # Set properties (e.g. setters) on the passed in object plus also invoke
  # any block passed against this object.
  # === Examples
  #
  #   with(grid, vgap: 2, hgap: 2) do
  #     set_pref_size(500, 400)
  #     children << location << go << view
  #   end
  #
  def with(obj, properties = {}, &block)
    populate_properties(obj, properties)

    if block_given?
      obj.extend(JRubyFX)
      obj.instance_eval(&block)
    end
    
    obj
  end

  ##
  # Convenience method so anything can safely schedule to run on JavaFX
  # main thread.
  def run_later(&block)
    Platform.run_later &block
  end

  ##
  # Create "build" a new JavaFX instance with the provided class and
  # set properties (e.g. setters) on that new instance plus also invoke
  # any block passed against this new instance.  This also can build a proc
  # or lambda form in which case the return value of the block will be what 
  # is used to set the additional properties on.
  # === Examples
  #
  #   grid = build(GridPane, vgap: 2, hgap: 2) do
  #     set_pref_size(500, 400)
  #     children << location << go << view
  #   end
  #
  #  build(proc { Foo.new }, vgap: 2, hgap: 2)
  #
  def build(klass, *args, &block)
    args, properties = split_args_from_properties(*args)

    obj = if klass.kind_of? Proc
      klass.call(*args)
    else
      klass.new(*attempt_conversion(klass, :new, *args))
    end

    with(obj, properties, &block)
  end

  def listener(mod, name, &block)
    obj = Class.new { include mod }.new
    obj.instance_eval do
      @name = name
      @block = block
      def method_missing(msg, *a, &b)
        @block.call(*a, &b) if msg == @name
      end
    end
    obj
  end
  module_function :listener
end
