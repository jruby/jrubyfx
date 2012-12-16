=begin
JRubyFXML - Write JavaFX and FXML in Ruby
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

require 'java'
require 'jruby/core_ext'

#not sure if I like this hackyness, but is nice for just running scripts.
#This is also in the rakefile
require ((Java.java.lang.System.getProperties["java.runtime.version"].match(/^1.7.[0123456789]+.(0[456789]|[1])/) != nil) ?
    Java.java.lang.System.getProperties["sun.boot.library.path"].gsub(/[\/\\][amdix345678_]+$/, "") + "/" : "") + 'jfxrt.jar'

require_relative 'fxml_application'
require_relative 'fxml_controller'
require_relative 'java_fx_impl'
