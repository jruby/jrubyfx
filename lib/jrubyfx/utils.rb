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

# This feels kinda like a hack. If anyone has a better idea, please let me know

# Standard ruby Hash class extensions
class Hash

  # call-seq:
  #   flat_tree_inject() {|results, key, value| block} => array
  #   flat_tree_inject(Hash) {|results, key, value| block} => hash
  #   
  # Execute given block against all nodes in the hash tree, returning `results`.
  # Similar to Hash#each except goes into all sub-Hashes
  #
  def flat_tree_inject(klass=Array,&block)
    self.inject(klass.new) do |lres, pair|
      if pair[1].is_a? Hash
        pair[1] = pair[1].flat_tree_inject(klass, &block)
      end
      block.call(lres, *pair)
    end
  end
end

# Standard ruby String class extensions
class String
  # call-seq:
  #   snake_case() => string
  #   
  # Converts a CamelCaseString to a snake_case_string
  # 
  #   "JavaFX".snake_case #=> "java_fx"
  #
  def snake_case
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end