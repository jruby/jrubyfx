=begin
JRubyFX - Write JavaFX and FXML in Ruby
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

require 'java' # for java_import
require 'jruby/core_ext' # for the become_java!

# JRubyFX includes
require_relative 'jrubyfx/jfx_imports'
require_relative 'jrubyfx/fxml_module'
require_relative 'jrubyfx/dsl'
require_relative 'jrubyfx/fxml_application'
require_relative 'jrubyfx/fxml_controller'
require_relative 'jrubyfx/java_fx_impl'
