JRubyFXML
=======
JRuby wrapper for JavaFX 2.x with FXML support (based on JRubyFX)

BUILD
-----
The default ant script expects the JavaFX runtime JAR in build_lib.
It should be found in `$JAVA_HOME/jre/lib/jfxrt.jar` for a suitable
JDK/JRE.

Then, run

```text
    ant
```

SAMPLES
-------

To run samples:

```text
   ant run
```
At the prompt specify the .rb file representing your jrubyfx script to execute.

LICENSE
-------
LGPLv3+. See LICENSE.

AUTHORS
-------
- Patrick Plenefisch
- Hiroshi Nakamura (JRubyFX)
- Hiro Asari (JRubyFX)
- Thomas E Enebo (JRubyFX)

