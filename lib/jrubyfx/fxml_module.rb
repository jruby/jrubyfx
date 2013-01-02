=begin
JRubyFX - Write JavaFX and FXML in Ruby
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

require 'jrubyfx'
require 'jrubyfx/utils/common_utils'

# This module contains useful methods for defining JavaFX code. Include it in your
# class fo use it, and the JFXImports. FXApplication and FXController already include it.
module JRubyFX
  include JFXImports
  include JRubyFX::Utils::CommonUtils

  ##
  # call-seq:
  #   with(obj, hash) => obj
  #   with(obj) { block } => obj
  #   with(obj, hash) { block }=> obj
  #   
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
      # cache the proxy - http://wiki.jruby.org/Persistence
      obj.class.__persistent__ = true if obj.class.ancestors.include? JavaProxy
      obj.extend(JRubyFX)
      obj.instance_eval(&block)
    end
    
    obj
  end

  ##
  # call-seq:
  #   run_later { block }
  # 
  # Convenience method so anything can safely schedule to run on JavaFX
  # main thread.
  def run_later(&block)
    Platform.run_later &block
  end

  ##
  # call-seq:
  #   build(class) => obj
  #   build(class, hash) => obj
  #   build(class) { block } => obj
  #   build(class, hash) { block } => obj
  #   
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

  # Attach a listener to a module with some voodoo.
  # TODO: Document this
  def listener(mod, name, &block)
    obj = Class.new { include mod }.new
    obj.instance_eval do
      @name = name
      @block = block
      def method_missing(msg, *a, &b) #:nodoc:
        @block.call(*a, &b) if msg == @name
      end
    end
    obj
  end
  module_function :listener
end

