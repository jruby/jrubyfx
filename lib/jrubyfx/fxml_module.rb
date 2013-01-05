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

require 'jrubyfx'
require 'jrubyfx/utils/common_utils'

# This module contains useful methods for defining JavaFX code. Include it in your
# class to use it, and the JRubyFX::FXImports. JRubyFX::Application and JRubyFX::Controller already include it.
module JRubyFX
  include JRubyFX::FXImports
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
end

