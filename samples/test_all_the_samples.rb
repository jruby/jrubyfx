#!/usr/bin/env jruby
=begin
JRubyFX - Write JavaFX and FXML in Ruby
Copyright (C) 2013 The JRubyFX Team

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end
$fulldir = File.expand_path(File.dirname(__FILE__))
def run(file)
  if file.end_with? ".rb" and File.executable? file
    puts " #{Dir.pwd}/#{file}"
    puts "="*80
    
    system("jruby -I #{$fulldir}/../lib '#{file}'")
  
    puts "="*80
  end
end
puts "="*80
Dir.chdir(File.dirname(__FILE__)) do
  ['fxml', 'javafx'].each do |ndir|
    Dir.foreach(ndir) do |filename|
      run("#{ndir}/#{filename}") unless ['.','..'].include?(filename)
    end
  end
  Dir.foreach('contrib') do |ndir|
    Dir.foreach('contrib/' + ndir) do |filename|
      Dir.chdir('contrib/' + ndir) do
        run(filename)
      end unless ['.','..'].include?(filename)
    end unless ['.','..'].include?(ndir)
  end
end
