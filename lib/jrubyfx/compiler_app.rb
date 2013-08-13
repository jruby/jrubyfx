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

# This class is used by the rake task to compile fxml files
class CompilerApp < JRubyFX::Application
  def start(stage)
    begin
      args = parameters.raw.to_a
      if args.include? "--"
        ar, requires = split(args, "--")
        requires.each {|x| require x}
        ar
      else
        args
      end.each do |arg|
        loader = FxmlLoader.new
        loader.location = URL.new "file:#{arg}"
        loader.controller = Object.new
        puts "Compiling #{arg}..."
        loader.load(jruby_ext: {jit: 0, dont_load: true, jit_opts: {force: true}})
      end
      puts "done"
    ensure
      Platform.exit
    end
  end

  def split(arr, delim)
    index = arr.index(delim)
    first = arr[0...index]
    second = arr[(index+1)..-1]
    return first, second
  end
end
