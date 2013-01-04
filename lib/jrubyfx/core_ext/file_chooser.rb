# JRubyFX DSL extensions for JavaFX FileChooser
class Java::javafx::stage::FileChooser

  # call-seq:
  #   add_extension_filter(description)
  #   add_extension_filter(description, filter)
  #   add_extension_filter(description, [filter, ...])
  # 
  # Takes ether a straight descriptions with embedded (*.whatnot) filter, or
  # separately, where filter can be an array or a string. Note that without a 
  # filter, the description MUST contain a list of extensions in parens.
  # === Examples
  #   add_extension_filter("Ruby Files (*.rb)")
  #   add_extension_filter("Ruby Files (*.rb)", "*.rb")
  #   add_extension_filter("Ruby Files (*.rb)", ["*.rb", "*.rbw"])
  #
  def add_extension_filter(desc, filter=nil)
    if filter == nil
      # Attempt to parse out list of stuff in parens
      filter = desc.match(/\(([\*\.\w;:, ]+)\)$/)[1] # grab everthing inside last parens
      filter = filter.split(/[:; ,]/).delete_if(&:empty?)
    end
    filter = [filter] unless filter.is_a? Array
    extension_filters.add(ExtensionFilter.new(desc.to_s, filter))
  end
  
  # call-seq:
  #   add_extension_filters([description, ...])
  #   add_extension_filters({description => filter, ...})
  #   add_extension_filters({description => [filter, ...], ...})
  # 
  # Takes a straight list of descriptions with embedded (*.whatnot) filters, or
  # a hash of "description" => "*.whatnot" or a hash of "description => ["*.whatnot", "*.etc"]
  # === Examples
  #   add_extension_filters(["Ruby Files (*.rb)", "Python Files (*.py)"])
  #   add_extension_filters({"Ruby Files (*.rb)" => "*.rb", "Python Files (*.py)" => ["*.py", "*.pyc"]})
  #
  def add_extension_filters(filters)
    #works with both arrays and hashes
    filters.each do |filters|
      add_extension_filter(*filters)
    end
  end
end
