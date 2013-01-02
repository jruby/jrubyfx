require 'jrubyfx'

# JRubyFX DSL extensions for JavaFX ObservableValues
module Java::javafx::beans::value::ObservableValue
  include JRubyFX # FIXME: Listener support should be own module

  java_import Java::javafx.beans.value.ChangeListener

  def add_change_listener(&block)
    add_listener(JRubyFX.listener(ChangeListener, :changed, &block))
    # Should work but gets access issues
    #    java_send :addListener, [ChangeListener.java_class], block
  end

  # FIXME: Not sure how to remove with this API.  We are passing in a proc
  # and we would need to examine each proc to determine which listener to
  # remove.  Probably a way to do it in each derived real class which actually
  # stores the listeners.
end
