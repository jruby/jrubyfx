

# OpenJFX

OpenJFX used was prebuilt library downloaded from [https://gluonhq.com/products/javafx/](https://gluonhq.com/products/javafx/) as that is referred by [https://openjfx.io](https://openjfx.io) download link.

Java used to run the test is
* openjdk version "11.0.7" 2020-04-14

Ruby used to run the test is
* jruby 9.2.9.0 (2.5.7) 2019-10-30 458ad3e OpenJDK 64-Bit Server VM 11.0.7+10-post-Ubuntu-2ubuntu218.04 on 11.0.7+10-post-Ubuntu-2ubuntu218.04 +jit [linux-x86_64]

OS used to run the test is
* Linux Mint 19.3 Tricia x86\_64, kernel 5.3.0-51-generic

The OpenJFX version used in this integration and tested are:
* version 11.0.7
* version 14.0.1
* version 15

After integrated, the samples/test\_all\_the\_samples.rb was run:

| Demo App                       | version 11.0.7 | version 14.0.1 | version 15 |
| ------------------------------- | ------------- | -------------- | ---------- |
| samples/fxml/Demo.rb           |   Success             |   Success             |  Success   |
| samples/javafx/binding\_app.rb |  Success              |   Success             |  Success   | 
| samples/javafx/movie\_app.rb   |  Success              |   Success             |  Success   | 
| samples/javafx/movie\_app.rb   |   No movie is shown but using Oracle Java yield the same result. Media key detected.              |   No movie is shown but using Oracle Java yield the same result. Media key detected.              |  No movie is shown but using Oracle Java yield the same result. Media key detected. | 
| samples/javafx/tree\_view.rb   |  Success              |   Success             |  Success   | 
| samples/javafx/image\_view\_with\_multi\_touch.rb  |   Success            |   Success             |  Success   | 
| samples/javafx/hello\_jrubyfx.rb  |  Success             |   Success             |  Success   | 
| samples/javafx/analog\_clock.rb  |  Success            |  Success              |  Success   | 
| samples/javafx/line\_chart.rb  |  Success              |  Success              |  Success   | 
| samples/javafx/scratchpad.rb   |  Success              | Success               |  Success   | 
| samples/javafx/table\_app.rb   |  Success              |  Success              |  Success   | 
| samples/javafx/hello\_devoxx.rb  | Success             |  Success              |  Success   | 
| samples/contrib/concurrency\_demos/progress\_bar\_task\_demo.rb  |  Success             |    Success            |  Success   | 
| samples/contrib/fxmlexample/FXMLExample.rb  | Success. But CSS seems not loaded     |    Success. But CSS seems not loaded          |  Success. But CSS seems not loaded   | 
| samples/contrib/fxmltableview/FXMLTableView.rb  |    Success     |    Success            |  Success   | 
| samples/contrib/binding\_examples/binding\_demo.rb  |  Success   |    Success            |  Success. Output 3 & 4   | 


Running the ruby files inside tests/

|                   | version 11.0.7 | version 14.0.1 | version 15 |
| ----------------- | -------------- | -------------- | ---------- |
| bindings.rb       |   Success             |    Success            |  Success   |
| bug.rb            |   Success             |   Success             |  Success   |
| ctrl.rb           |   \*note 1             |   \*note 1              |  \*note 1   |
| Hello.rb          |   Success             |   Success             |  Success   |
| js.rb             |   Failed as error in note 2  |  Failed as error in note 2   |  Failed as error in note 2   |
| jsCtrl.rb         |   Failed as error in note 2  |   Failed as error in note 2  |  Failed as error in note 2   |
| jsNoCtrl.rb       |   Failed as error in note 2  |  Failed as error in note 2   |  Failed as error in note 2   |
| noCtrl.rb         |   \*similar to note 1        |    \*similar to note 1       |  \*similar to note 1   |
| jsNoCtrl.rb       |   Failed as error in note 2  |   Failed as error similar to note 2   |  Failed as error similar to note 2   |



\* note 1: Window shown, error shown on console:
  JIT compiled method for file:/media/chris/vdata/opensource/jrubyfx-openjfx-patch/jrubyfx/tests/ctrl.fxml FAILED with error:
  can't modify frozen NilClass
  org/jruby/RubyKernel.java:2263:in `instance_variable_set'

\* note 2: Exception in thread "JavaFX Application Thread" java.lang.NoClassDefFoundError: javax/script/ScriptEngineFactory


