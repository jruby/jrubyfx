=begin
JRubyFXML - Write JavaFX and FXML in Ruby
Copyright (C) 2013 Patrick Plenefisch

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

##
# Inherit from this class for FXML Applications. You must use this class for both
# raw JavaFX and FXML as it contains the launch method.
class FXApplication < Java.javafx.application.Application
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
