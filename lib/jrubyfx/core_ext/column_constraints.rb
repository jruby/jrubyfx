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
require 'jrubyfx/dsl'

# JRubyFX DSL extensions for JavaFX Column Constraints
class Java::javafx::scene::layout::ColumnConstraints
  extend JRubyFX::Utils::CommonConverters
  
  constrain = map_converter(constrain_to_pref: CONSTRAIN_TO_PREF,
                            constrain: CONSTRAIN_TO_PREF,
                            pref: CONSTRAIN_TO_PREF,
                            preferred: CONSTRAIN_TO_PREF)

  converter_for :new, [], [:none], [:none, :none, constrain], [:none, :none, constrain, :none, :none, :none]

end

# JRubyFX DSL extensions for JavaFX Row Constraints
class Java::javafx::scene::layout::RowConstraints
  extend JRubyFX::Utils::CommonConverters
  
  constrain = map_converter(constrain_to_pref: CONSTRAIN_TO_PREF,
                            constrain: CONSTRAIN_TO_PREF,
                            pref: CONSTRAIN_TO_PREF,
                            preferred: CONSTRAIN_TO_PREF)

  converter_for :new, [], [:none], [:none, :none, constrain], [:none, :none, constrain, :none, :none, :none]

end
