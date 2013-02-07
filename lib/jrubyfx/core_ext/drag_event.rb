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
require 'jrubyfx/utils/common_converters'

# JRubyFX DSL extensions for JavaFX drag events
class Java::javafx::scene::input::DragEvent
  extend JRubyFX::Utils::CommonConverters
  include JRubyFX::Utils::CommonUtils

  tmc = enum_converter(Java::javafx::scene::input::TransferMode)
  converter_for :accept_transfer_modes, &tmc

  # FIXME: For non-dsl calls like this we want converter logic
  alias :accept_transfer_modes_orig :accept_transfer_modes
  def accept_transfer_modes(*values)
    accept_transfer_modes_orig *attempt_conversion(self, "accept_transfer_modes", *values)
  end
end
