require 'jrubyfx/utils/inspector'

# Inject the Inspector into all JavaFX Node descendants (most objects)
Java::JavafxScene::Node.send :include, JRubyFX::Utils::Inspector
