#!/usr/bin/env jruby
=begin
Original Java source from: http://docs.oracle.com/javafx/2/threads/jfxpub-threads.htm
/*
 * Copyright (c) 2011, 2012 Oracle and/or its affiliates.
 * All rights reserved. Use is subject to license terms.
 *
 * This file is available and licensed under the following license:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *  - Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  - Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the distribution.
 *  - Neither the name of Oracle nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
=end

require 'jrubyfx'

class MyTask < javafx.concurrent.Task
  def initialize(max_val=1000000)
    @max_val = max_val
  end

  def call
    puts "inside call"
    (1..@max_val).each do |i|
      if is_cancelled
        break
      end
      puts i
      updateProgress(i, @max_val)
    end
  end
end

class MyService < javafx.concurrent.Service
  def initialize(bar)
    @bar = bar
    super()
  end

  def createTask
    MyTask.new.tap do |t|
      t.set_on_cancelled do |event|
        puts "task cancelled"
      end

      t.set_on_failed do |event|
        puts "task failed #{event.to_s}: #{@bar.progress}"
      end
    end
  end
end

class ProgressBarWithServiceDemo < JRubyFX::Application
  def start(stage)
    with(stage, title: "Progress Bar Demo with binded Task", width: 200,
         height: 100) do
      layout_scene do
        vbox(15, alignment: Java::javafx.geometry.Pos::CENTER) do
          progress_bar(id: 'bar')
          button("restart")
        end
      end
    end

    stage['.button'].set_on_action { restart_task }
    bar = stage['#bar']
    @my_service = MyService.new(bar)
    bar.progress_property.bind(@my_service.progress_property)

    @my_service.start
    stage.show
  end

  def restart_task
    @my_service.restart
  end
end

ProgressBarDemo.launch
