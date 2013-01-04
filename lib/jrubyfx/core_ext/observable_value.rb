require 'jrubyfx'

# JRubyFX DSL extensions for JavaFX ObservableValues
module Java::javafx::beans::value::ObservableValue
  java_import Java::javafx.beans.value.ChangeListener

  ##
  # call-seq:
  #   add_change_listener { |observable, old_value, new_value| block }
  #   
  # Add a ruby block to call when the property changes changes
  def add_change_listener(&block)
    java_send :addListener, [ChangeListener.java_class], block
  end

  # FIXME: Not sure how to remove with this API.  We are passing in a proc
  # and we would need to examine each proc to determine which listener to
  # remove.  Probably a way to do it in each derived real class which actually
  # stores the listeners.
end
