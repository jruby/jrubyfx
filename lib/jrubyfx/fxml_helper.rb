require 'java'
require 'jruby/core_ext'

module JRubyFX::FxmlHelper
  include_package 'javax.xml.stream'
  include_package 'javafx.fxml'
  import 'java.nio.charset.Charset'

  # fxmlloader transformer, modifies clazz to be compatible with the fxml file
  def self.transform(clazz, fxml_url)
    packages = []
    classes = {}
    attribs = []
    
    begin
  
      # Read in the stream and set everything up
      
      inputStream = fxml_url.open_stream
      xmlInputFactory = XMLInputFactory.newFactory
      xmlInputFactory.setProperty("javax.xml.stream.isCoalescing", true)

      # Some stream readers incorrectly report an empty string as the prefix
      # for the default namespace; correct this as needed
      inputStreamReader = java.io.InputStreamReader.new(inputStream, Charset.forName("UTF-8"))
      xmlStreamReader = xmlInputFactory.createXMLStreamReader(inputStreamReader)

      # set up a quick map so we can easily look up java return values with jruby values for the xml events
      dm = Hash[XMLStreamConstants.constants.map {|x| [XMLStreamConstants.const_get(x), x] }]
    
      lastType = nil
      while xmlStreamReader.hasNext
        event = xmlStreamReader.next
        
        case dm[event]
        when :PROCESSING_INSTRUCTION
          # PI's needs to be added to our package list
          if xmlStreamReader.pi_target.strip == FXMLLoader::IMPORT_PROCESSING_INSTRUCTION
            name = xmlStreamReader.pi_data.strip
            
            # importing package vs class
            if name.end_with? ".*" 
              packages << name[0...-2] # strip the .* and add to package list
            else
              i = name.index('.') # find the package/class split, should probably be backwards, but eh
              i = name.index('.', i + 1) while i && i < name.length && name[i + 1] == name[i + 1].downcase
                
              if i.nil? or i+1 >= name.length
                raise LoadException.new(NameError.new(name))#TODO: rubyize the stack trace TODO: test
              end
                
              class_name = name[(i + 1)..-1]
              pkg_name = "#{name[0...i]}.#{class_name.gsub('.', '$')}"
              
              # now that we have the class name, look it up and add to the list, or if failure, assume ruby
              classes[class_name] = begin
                JavaUtilities.get_proxy_class(pkg_name).java_class.to_java
              rescue NameError => ex # probably ruby class
                begin
                  pkg_name.constantize_by(".")
                rescue
                  raise LoadException.new(NameError.new(pkg_name)) # nope, not our issue anymore TODO: rubyize?
                end
              end
            
            end
          end
        when :START_ELEMENT
          # search start elements for ID's that we need to inject on init
          lastType = xmlStreamReader.local_name
          
          # search all atttribues for id and events
          xmlStreamReader.attribute_count.times do |i|
            prefix = xmlStreamReader.get_attribute_prefix(i)
            localName = xmlStreamReader.get_attribute_local_name(i)
            value = xmlStreamReader.get_attribute_value(i)

            # if it is an id, save the id and annotate it as injectable by JavaFX. Default to object since ruby land doesn't care...
            if localName == "id" and prefix == FXMLLoader::FX_NAMESPACE_PREFIX
              #puts "GOT ID! #{lastType} #{value}"
              attribs << value
              
              # add the field to the controller
              clazz.instance_eval do
                # Note: we could detect the type, but Ruby doesn't care, and neither does JavaFX's FXMLLoader 
                java_field "@javafx.fxml.FXML java.lang.Object #{value}", bind_variable: true
              end
            # otherwise, if it is an event, add a forwarding call
            elsif localName.start_with? "on" and value.start_with? "#"
              mname = value[1..-1] # strip hash
              aname = "jrubyfx_aliased_#{mname}"

              # TODO: use java proxy rewrites
              # add the method to the controller by aliasing the old method, and replacing it with our own fxml-annotated forwarding call
              clazz.instance_eval do
                alias_method aname.to_sym, mname.to_sym if method_defined? mname.to_sym
                java_signature "@javafx.fxml.FXML void #{mname}(javafx.event.Event)"
                define_method(mname) do |e|
                  if respond_to? aname
                    if method(aname).arity == 0
                      send(aname)
                    else
                      send(aname, e)
                    end
                  else
                    puts "Warning: method #{mname} was not found on controller #{self}"
                  end
                end
              end
              
            end
          end
        end
      end
      # poorly dispose of stream reader
      xmlStreamReader = nil

      # have to jump through hoops to set the classwide list
      class << clazz
        define_method :__jruby_set_insts, &(lambda {|list|
          @__jrubyfx_fxml_ids = list
        })
        define_method :__jruby_get_insts, &(lambda {
          @__jrubyfx_fxml_ids
        })
      end
      clazz.__jruby_set_insts(attribs)

      clazz.become_java!
    rescue XMLStreamException => exception
      raise (exception)
    end
  end
end
