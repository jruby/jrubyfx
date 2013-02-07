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

# JRubyFX DSL extensions for JavaFX Tree views
class Java::javafx::scene::control::TreeView
  include JRubyFX::DSL

  ##
  # get_tree_item interferes with idiomatic construction of a root
  # tree_item.  We override and users should use get_tree_item(i)
  # if they want the original method.
  def tree_item(*args, &block)
    method_missing(:tree_item, *args, &block)
  end

  ##
  # Add any child tree items as the root node.  Note, that there
  # is only one root and successive tree_items in a tree_view will
  # keep replacing the root.
  def method_missing(name, *args, &block)
    super.tap do |obj|
      set_root(obj) if obj.kind_of? TreeItem
    end
  end
end
