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

# JRubyFX DSL extensions for JavaFX TableViews
class Java::javafx::scene::control::TableView
  java_import Java::javafx.scene.control.TableColumn

  extend JRubyFX::Utils::CommonConverters

  resize_policy = map_converter(unconstrained_resize_policy: UNCONSTRAINED_RESIZE_POLICY,
                                constrained_resize_policy: CONSTRAINED_RESIZE_POLICY,
                                unconstrained: UNCONSTRAINED_RESIZE_POLICY,
                                constrained: CONSTRAINED_RESIZE_POLICY)

  converter_for :column_resize_policy, [resize_policy]
end
