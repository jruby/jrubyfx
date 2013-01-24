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

# JRubyFX DSL extensions for JavaFX Progress *
class Java::javafx::scene::control::ProgressIndicator
  extend JRubyFX::Utils::CommonConverters
  
  progress_conv = map_converter(indeterminate_progress: INDETERMINATE_PROGRESS,
                                indeterminate: INDETERMINATE_PROGRESS)

  converter_for :progress, [progress_conv]
  converter_for :new, [], [progress_conv]

end

# JRubyFX DSL extensions for JavaFX Progress *
class Java::javafx::scene::control::ProgressBar
  extend JRubyFX::Utils::CommonConverters
  
  progress_conv = map_converter(indeterminate_progress: INDETERMINATE_PROGRESS,
                                indeterminate: INDETERMINATE_PROGRESS)

  converter_for :progress, [progress_conv]
  converter_for :new, [], [progress_conv]

end
