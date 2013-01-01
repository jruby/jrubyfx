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

require 'java' # for java_import
require 'jruby/core_ext' # for the become_java!

# JRubyFXML includes
require_relative 'jfx_imports'
require_relative 'fxml_module'
require_relative 'jrubyfx/dsl'
require_relative 'fxml_application'
require_relative 'fxml_controller'
require_relative 'java_fx_impl'

# JRubyFX DSL
# FIXME: core_ext could be loaded on demand through dsl API if we only had
# dsl API.
require_relative 'jrubyfx/core_ext/node'
require_relative 'jrubyfx/core_ext/circle'
require_relative 'jrubyfx/core_ext/labeled'
require_relative 'jrubyfx/core_ext/observable_value'
require_relative 'jrubyfx/core_ext/parent'
require_relative 'jrubyfx/core_ext/parallel_transition'
require_relative 'jrubyfx/core_ext/path'
require_relative 'jrubyfx/core_ext/radial_gradient'
require_relative 'jrubyfx/core_ext/scene'
require_relative 'jrubyfx/core_ext/shape'
require_relative 'jrubyfx/core_ext/stage'
require_relative 'jrubyfx/core_ext/stop'
require_relative 'jrubyfx/core_ext/table_view'
require_relative 'jrubyfx/core_ext/timeline'
require_relative 'jrubyfx/core_ext/xy_chart'
require_relative 'jrubyfx/core_ext/border_pane'
