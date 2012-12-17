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

require_relative 'jfx_imports'
require_relative 'fxml_application'
require_relative 'fxml_controller'
require_relative 'java_fx_impl'

# FIXME: core_ext could be loaded on demand through dsl API if we only had
# dsl API.
require 'jrubyfx.jar'
require 'jrubyfx/utils/common_utils'
require 'jrubyfx/core_ext/node'
require 'jrubyfx/core_ext/circle'
require 'jrubyfx/core_ext/labeled'
require 'jrubyfx/core_ext/observable_value'
require 'jrubyfx/core_ext/parent'
require 'jrubyfx/core_ext/parallel_transition'
require 'jrubyfx/core_ext/path'
require 'jrubyfx/core_ext/radial_gradient'
require 'jrubyfx/core_ext/scene'
require 'jrubyfx/core_ext/shape'
require 'jrubyfx/core_ext/stage'
require 'jrubyfx/core_ext/stop'
require 'jrubyfx/core_ext/table_view'
require 'jrubyfx/core_ext/timeline'
require 'jrubyfx/core_ext/xy_chart'
require 'jrubyfx/core_ext/border_pane'