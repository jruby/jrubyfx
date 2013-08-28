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

##
# Inherit from this class for FXML Applications. You must use this class for both
# raw JavaFX and FXML as it contains the launch method.
class JRubyFX::Application < Java.javafx.application.Application
  include JRubyFX
  include JRubyFX::DSL

  ##
  # Are we packaged in a jar? This does some comparison, and may get false positives
  # and, if jruby changes, false negatives. If you are using this, it might be a
  # very bad idea... (though it is handy)
  def self.in_jar?()
    $LOAD_PATH.inject(false) { |res,i| res || i.include?(".jar!/META-INF/jruby.home/lib/ruby/")}
  end

  ##
  # call-seq:
  #   launch()
  #
  # When called on a subclass, this is effectively our main method.
  def self.launch(*args)
    #call our custom launcher to avoid a java shim
    JavaFXImpl::Launcher.launch_app(self, *args)
  end
end
