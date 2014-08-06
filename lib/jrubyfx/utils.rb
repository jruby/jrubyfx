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

# This feels kinda like a hack. If anyone has a better idea, please let me know

# Standard ruby Hash class extensions
class Hash

  # call-seq:
  #   flat_tree_inject() {|results, key, value| block} => array
  #   flat_tree_inject(Hash) {|results, key, value| block} => hash
  #
  # Execute given block against all nodes in the hash tree, returning `results`.
  # Similar to Hash#each except goes into all sub-Hashes
  #
  def flat_tree_inject(klass=Array,&block)
    self.inject(klass.new) do |lres, pair|
      if pair[1].is_a? Hash
        pair[1] = pair[1].flat_tree_inject(klass, &block)
      end
      block.call(lres, *pair)
    end
  end
end

# Standard ruby String class extensions
class String
  # call-seq:
  #   snake_case() => string
  #
  # Converts a CamelCaseString to a snake_case_string
  #
  #   "JavaFX".snake_case #=> "java_fx"
  #
  def snake_case
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end

module Enumerable
  def map_find(&block)
    m = {}
    m[self.find do |i|
      m[i] = block.call(i)
    end]
  end
end

module JRubyFX
  def self.load_fx(force=false)
    return if @already_loaded_fx and !force
    @already_loaded_fx = true
    java.util.concurrent.CountDownLatch.new(1).tap do |latch|
      com.sun.javafx.application.PlatformImpl.startup { latch.countDown }
      latch.await
    end
  end
end
