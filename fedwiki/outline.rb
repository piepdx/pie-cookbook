# summarize the markup of the docs
# usage: ruby outline.rb

File.read('../docs/pie-cookbook-0.9.md',:encoding=>'utf-8').split(/\n\s*/).each do |line|
  if line[0] == '#'
    puts "\n",line
  else
    print line[0] unless line.match /^[a-zA-Z]/
    puts line.split().map {'.'}.join
  end
end
puts