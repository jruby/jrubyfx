#usage:
# unzip javafx jars to . (on linux, possibly: for f in /usr/share/openjfx/lib/*.jar; do b=`basename $f .jar`; unzip $f -d $b/; done)
# for x in $(find javafx -name '*.class'); do javap $x | head -n 2; done | grep public | sed -n 's/^.* \(interface\|class\) \(javafx.[^ <]\+\)\(<.*>\)\? .*$/\2/p' | grep -v '\$'  | sort -u | ruby gen_tree.rb
# Look for duplicates and unexported packages
# Paste the output in part_import


tree = {}

names = {}
names.default = false

ignores = %w[javafx.css.converter.StringConverter]

# Note: this ignores nested packages (Parent$Nested)
ARGF.each_line do |line|
	next if ignores.include? line.strip
	*pkg, name = line.split(".")
	leaf = pkg.inject(tree) do |branch, package|
		(branch[package.to_sym] ||= {})
	end
	(leaf[''] ||= []) << name.strip
	if names[name]
		warn "#{name.strip} is a duplicate"
	end
	names[name] = true
end

def print_tree(branch, indent="      ")
	if branch.is_a? Array
		return "%w[#{branch.join(" ")}],"
	elsif branch.size == 1 && branch.has_key?("")
		return "%w[#{branch[''].join(" ")}],"
	else
		return ["{",  *(branch.map{|k, v| "#{k.inspect.gsub('"',"'")} => #{print_tree(v, indent+"  ")}"}), "},"].join("\n#{indent}")
	end
end

puts print_tree(tree).gsub(/  }/, "}")
