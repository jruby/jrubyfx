class Java::javafx::stage::FileChooser

  # Takes ether a straight descriptions with embedded (*.whatnot) filter, or
  # seperatly, where filter can be an array or a string
  def add_extension_filter(desc, filter=nil)
    if filter == nil
      # Attempt to parse out list of stuff in parens
      filter = desc.match(/\(([\*\.\w;:, ]+)\)$/)[1] # grab everthing inside last parens
      filter = filter.split(/[:; ,]/).delete_if(&:empty?)
    end
    filter = [filter] unless filter.is_a? Array
    extension_filters.add(ExtensionFilter.new(desc.to_s, filter))
  end
  
  # Takes a straight list of descriptions with embedded (*.whatnot) filters, or
  # a hash of "description" => "*.whatnot" or a hash of "description => ["*.whatnot", "*.etc"]
  def add_extension_filters(filters)
    #works with both arrays and hashes
    filters.each do |filters|
      add_extension_filter(*filters)
    end
  end
end
