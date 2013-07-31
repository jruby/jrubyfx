# See http://docs.oracle.com/javafx/2/threads/jfxpub-threads.htm
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

class ProgressBarDemo < JRubyFX::Application
  def start(stage)
    with(stage, title: "Progress Bar Demo with binded Task", width: 400,
         height: 150) do
      layout_scene do
        progress_bar(id: 'bar')
      end
    end
    my_task = MyTask.new
    bar = stage['#bar']
    bar.progress_property.bind(my_task.progress_property)
    Java::java.lang.Thread.new(my_task).start

    stage.show
  end
end

ProgressBarDemo.launch
