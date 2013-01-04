#!/usr/bin/env jruby
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
