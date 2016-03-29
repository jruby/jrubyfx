require 'jruby/core_ext'
require_relative '../jrubyfx' # TODO!

module JRubyFX::FxmlHelper

  # fxmlloader transformer, modifies clazz to be compatible with the fxml file
  def self.fxml_keys(clazz, fxml_url)
    packages = []
    classes = {}
    attribs = []
    
    begin
  
      # Read in the stream and set everything up
      
      inputStream = fxml_url.open_stream
      xmlInputFactory = Java::javax.xml.stream.XMLInputFactory.newFactory
      xmlInputFactory.setProperty("javax.xml.stream.isCoalescing", true)

      # Some stream readers incorrectly report an empty string as the prefix
      # for the default namespace; correct this as needed
      inputStreamReader = java.io.InputStreamReader.new(inputStream, java.nio.charset.Charset.forName("UTF-8"))
      xmlStreamReader = xmlInputFactory.createXMLStreamReader(inputStreamReader)

      # set up a quick map so we can easily look up java return values with jruby values for the xml events
      dm = Hash[javax.xml.stream.XMLStreamConstants.constants.map {|x| [javax.xml.stream.XMLStreamConstants.send(x), x] }]
    
      lastType = nil
      while xmlStreamReader.hasNext
        event = xmlStreamReader.next
        
        case dm[event]
        when :PROCESSING_INSTRUCTION
          # PI's needs to be added to our package list
          if xmlStreamReader.pi_target.strip == javafx.fxml.FXMLLoader::IMPORT_PROCESSING_INSTRUCTION
            name = xmlStreamReader.pi_data.strip
            
            # importing package vs class
            if name.end_with? ".*" 
              packages << name[0...-2] # strip the .* and add to package list
            else
              i = name.index('.') # find the package/class split, should probably be backwards, but eh
              i = name.index('.', i + 1) while i && i < name.length && name[i + 1] == name[i + 1].downcase
                
              if i.nil? or i+1 >= name.length
                raise javafx.fxml.LoadException.new(ClassNotFoundException.new)
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
                  raise javafx.fxml.LoadException.new(ClassNotFoundException.new(pkg_name)) # nope, not our issue anymore
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
            if localName == "id" and prefix == javafx.fxml.FXMLLoader::FX_NAMESPACE_PREFIX
              #puts "GOT ID! #{lastType} #{value}"
              attribs << value
              
              # add the field to the controller
              clazz.instance_eval do
                java_annotation 'javafx.fxml.FXML'
                java_field "java.lang.Object #{value}"
              end
            # otherwise, if it is an event, add a forwarding call
            elsif localName.start_with? "on" and value.start_with? "#"
              puts "got Action #{localName} #{value}"
              mname = value[1..-1]
              aname = "jrubyfx_aliased_#{mname}"
              
              # add the method to the controller by aliasing the old method, and replacing it with our own fxml-annotated forwarding call
              clazz.instance_eval do
                alias_method aname.to_sym, mname.to_sym if method_defined? mname.to_sym
                java_annotation 'javafx.fxml.FXML'
                java_signature "void #{mname}(javafx.event.Event)"
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
      
      # once everything is done, define background helper methods to expose the base fxml values
   clazz.instance_eval do
      define_method :copy_fxml_instances do
        @@__jrubyfx_fxml_ids.each do |attrib|
            instance_variable_set("@#{attrib}", send(attrib)) # TODO: this could lead to bugs if the method aliases some ruby or java method name
          
        end
      end
    end
    # have to jump through hoops to set the classwide list
    class << clazz
      define_method :__jruby_set_insts, &->(list){
        @@__jrubyfx_fxml_ids = list
      }
    end
      clazz.__jruby_set_insts(attribs)
      clazz.become_java!
#      @new_controller = @new_controller.new(@controller).to_java
#      native = javafx.fxml.FXMLLoader.new(@location)
#      native.charset = @charset
#      native.controller = @new_controller
#      res = native.load
#      @new_controller.__jrubyfx_fxmlloader__dyn_copy(@attribs)
#      return res
    rescue Java::javax.xml.stream.XMLStreamException => exception
      raise (exception)
    end
  end
  
end

## TODO: Testing below here #################################################################
Basepath=ARGV[0].match(/file:\/\/(.*\/)[^\/]+.fxml/)[1]
fxml_root Basepath

# fxml controller that is converted to java
class AController
  # not at the moment
  #include JRubyFX::Controller
  
  def initialize
  	puts "hey, I was initialized"
  end
  
  def click_green(e)
    puts "GREEN CLICK"
    p @ui_border_pane
    copy_fxml_instances
    p @ui_border_pane
    p ui_border_pane
    p e
  end
  
  def click_blue
  	
    @ui_border_pane.bottom = complex_control("Enter text and hit enter:")
  end
  #fxml "Demo.fxml"
end

## Use the temporary loader to reformat AController
JRubyFX::FxmlHelper.fxml_keys AController, java.net.URL.new(ARGV[0])

class ComplexControl < Java::javafx::scene::layout::BorderPane
  #include JRubyFX::Controller
  #default one, also guessable from class name
  #fxml "ComplexControl.fxml"

  #optional
  #def java_ctor(ctor, initialize_args)
  #  ctor.call() # any arguments to BorderPane constructor go here
  #end

  def initialize
  	puts "cc init"
    #force override
    #load_fxml "ComplexControl.fxml"

    #@label.text = text
  end

  def text
    @textBox.text
  end
  def text=(v)
    @textBox.text = v
  end
  
  # This is an event handler
  def announce_it # optional: add argument e
    puts "Text box contains: #{text}"
    self.text = ""
  end
end

JRubyFX::FxmlHelper.fxml_keys ComplexControl, java.net.URL.new("file://#{Basepath}/ComplexControl.fxml")

########## The JRubyFX application launcher

# Inherit from JRubyFX::Application to create our Application
class SimpleFXApplication < JRubyFX::Application

  # we must override start to get a stage on application initialization
  def start(stage)
    
     native = javafx.fxml.FXMLLoader.new(java.net.URL.new(ARGV[0]))

    native.controller = AController.new
    p stage.scene = javafx.scene.Scene.new(native.load)
    stage.show
  end
end
SimpleFXApplication.launch

