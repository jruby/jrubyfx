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

# JRubyFX DSL extensions for JavaFX color stops
class Java::javafx::scene::layout::Region
  extend JRubyFX::Utils::CommonConverters
  
  use_sizes = map_converter(use_pref_size: USE_PREF_SIZE,
                            use_computed_size: USE_COMPUTED_SIZE,
                            pref_size: USE_PREF_SIZE,
                            computed_size: USE_COMPUTED_SIZE,
                            preferred_size: USE_PREF_SIZE,
                            compute_size: USE_COMPUTED_SIZE,
                            pref: USE_PREF_SIZE,
                            computed: USE_COMPUTED_SIZE,
                            preferred: USE_PREF_SIZE,
                            compute: USE_COMPUTED_SIZE)

  converter_for :min_width, [use_sizes]
  converter_for :min_height, [use_sizes]
  converter_for :pref_width, [use_sizes]
  converter_for :pref_height, [use_sizes]
  converter_for :max_width, [use_sizes]
  converter_for :max_height, [use_sizes]

  converter_for :padding, [:insets]
end
