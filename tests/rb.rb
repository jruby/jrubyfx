#!/usr/bin/env jruby
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

fxml_root File.dirname(__FILE__)

class ScriptFXApplication < JRubyFX::Application
  def start(stage)
    stage.title = "FXML with JavaScript"
    stage.width = 100
    stage.height = 100
    stage.fxml = ScriptFXController
    stage.show
  end
end

class ScriptFXController
  include JRubyFX::Controller
  fxml "rb.fxml"
  def hello
    puts "Whoa! Called from JavaScript! Groovy!"
  end
end

#puts "simple test no 1"
#sem = Java.javax.script.ScriptEngineManager.new
#sem.setBindings(javax.script.SimpleBindings.new({"resources" => nil, "controller"=>"who knows where"}))
#se = sem.getEngineByName("jruby")
#se.setBindings(sem.getBindings(), javax.script.ScriptContext::ENGINE_SCOPE)
#p se
#p se.eval("\n\n    def handleButtonAction(event)\n       puts('You clicked me!')\n\t   p event\n\t   $controller.hello();\n    end\n    ")
#puts "bindings are"
#p bins = se.getBindings(javax.script.ScriptContext::ENGINE_SCOPE)
#p newb = se.createBindings()
#newb.put("event", "an event!")
#se.setBindings(newb, javax.script.ScriptContext::ENGINE_SCOPE)
#p se.eval("handleButtonAction($event);")
#puts "now the real deal:"
ScriptFXApplication.launch
