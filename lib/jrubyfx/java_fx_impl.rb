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
#:nodoc: all

# Due to certain bugs in JRuby 1.7 (namely some newInstance mapping bugs), we
# are forced to re-create the Launcher if we want a pure ruby wrapper
# I can't wait to delete this. The _ONLY_ code that should use this is
# JRubyFX::Application.launch. Do _NOT_ use this code anywhere else.
module JavaFXImpl #:nodoc: all
  java_import 'com.sun.javafx.application.PlatformImpl'
  java_import 'javafx.stage.Stage'

  #JRuby, you make me have to create real classes!
  class FinisherInterface
    include PlatformImpl::FinishListener

    def initialize(&block)
      @exitBlock = block
    end

    def idle(someBoolean)
      @exitBlock.call
    end

    def exitCalled()
      @exitBlock.call
    end
  end

  class Launcher
    java_import 'java.util.concurrent.atomic.AtomicBoolean'
    java_import 'java.util.concurrent.CountDownLatch'
    java_import 'java.lang.IllegalStateException'
    java_import 'com.sun.javafx.application.ParametersImpl'

    @@launchCalled = AtomicBoolean.new(false) # Atomic boolean go boom on bikini

    def self.launch_app(classObj, new, *args)
      #prevent multiple!
      if @@launchCalled.getAndSet(true)
        throw IllegalStateException.new "Application launch must not be called more than once"
      end

      begin
        #create a java thread, and run the real worker, and wait till it exits
        count_down_latch = CountDownLatch.new(1)
        thread = Java.java.lang.Thread.new do
          begin
            launch_app_from_thread(classObj, new, args)
          rescue => ex
            puts "Exception starting app:"
            p ex
            p ex.backtrace
          end
          count_down_latch.countDown #always count down
        end
        thread.name = "JavaFX-Launcher"
        thread.start
        count_down_latch.await
      rescue => ex
        puts "Exception launching JavaFX-Launcher thread:"
        p ex
        puts ex.backtrace
      end
    end

    def self.launch_app_from_thread(classObj, new, args)
      #platformImpl startup?
      finished_latch = CountDownLatch.new(1)
      PlatformImpl.startup do
        finished_latch.countDown
      end
      finished_latch.await

      begin
        launch_app_after_platform(classObj, new, args) #try to launch the app
      rescue => ex
        puts "Error running Application:"
        p ex
        puts ex.backtrace
      end

      #kill the toolkit and exit
      PlatformImpl.tkExit
    end

    def self.launch_app_after_platform(classObj, new, args)
      #listeners - for the end
      finished_latch = CountDownLatch.new(1)

      # register for shutdown
      PlatformImpl.addListener(FinisherInterface.new {
          # this is called when the stage exits
          finished_latch.countDown
        })

      app = if new
        classObj.new
      else
        raise "Invalid type: cannot launch non-Application" unless classObj.is_a? Java::javafx.application.Application
        classObj
      end

      # Correct answer: yes
      ParametersImpl.registerParameters(app, ParametersImpl.new(args));

      app.init()

      error = false
      #RUN! and hope it works!
      PlatformImpl.runAndWait do
        begin
          stage = Stage.new
          stage.impl_setPrimary(true)
          app.start(stage)
          # no countDown here because its up top... yes I know
        rescue => ex
          puts "Exception running Application:"
          p ex
          puts ex.backtrace
          error = true
          finished_latch.countDown # but if we fail, we need to unlatch it
        end
      end

      #wait for stage exit
      finished_latch.await

      # call stop on the interface
      app.stop() unless error
    end
  end
end
