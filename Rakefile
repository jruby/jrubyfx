task :default => [:run]

task :run do
  puts Java.java.lang.System.getProperties["java.runtime.version"]
  ruby "-I lib:/usr/lib/jvm/java-7-oracle/jre/lib samples/SimpleFXMLDemo.rb"
end
