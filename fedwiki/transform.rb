# translate and upload to pie.fed.wiki
# usage: ruby transform.rb

require 'open3'
require 'json'

# wiki utilities

def random
  (1..16).collect {(rand*16).floor.to_s(16)}.join ''
end

def slug title
  title.gsub(/\s/, '-').gsub(/[^A-Za-z0-9-]/, '').downcase()
end

def clean text
  text.gsub(/’/,"'")
end

def url text
  text.gsub(/(http:\/\/)?([a-zA-Z0-9._-]+?\.(net|com|org|edu)(\/[^ )]+)?)/,'[http:\/\/\2 \2]')
end

def domain text
  text.gsub(/((https?:\/\/)(www\.)?([a-zA-Z0-9._-]+?\.(net|com|org|edu|us|cn|dk|au))(\/[^ );]*)?)/,'[\1 \4]')
end

def titalize text
  excluded = %w(the this that if and or not may any all in of by for at to be)
  text.capitalize!
  text.gsub! /[\[\]]/, ''
  text.gsub(/[\w']+/m) do |word|
      excluded.include?(word) ? word : word.capitalize
  end
end


# journal actions

def create title
  @journal << {'type' => 'create', 'id' => random, 'item' => {'title' => title}, 'date' => Time.now.to_i*1000}
end

def add item
  @story << item
  @journal << {'type' => 'add', 'id' => item['id'], 'item' => item, 'date' => Time.now.to_i*1000}
end


# story emiters

def paragraph text
  return if text =~ /^\s*$/
  text.gsub! /\r\n/, "\n"
  add({'type' => 'paragraph', 'text' => text, 'id' => random()})
end

def pagefold text, id = random()
  text.gsub! /\r\n/, ""
  add({'type' => 'pagefold', 'text' => text, 'id' => id})
end

def markdown text
  add({'type' => 'markdown', 'text' => text, 'id' => random()})
end

def html text
  add({'type' => 'html', 'text' => text, 'id' => random()})
end

def page title
  @story = []
  @journal = []
  create title
  yield
  page = {'title' => title, 'story' => @story, 'journal' => @journal}
  path = "pages/#{slug(title)}"
  File.open(path, 'w') do |file|
    file.write JSON.pretty_generate(page)
  end
end


# transformation

def ref title
  doc = 'https://github.com/WardCunningham/pie-cookbook/blob/master/docs/pie-cookbook-0.9.md'
  "[#{doc}##{slug(title)} ref]"
end

`rm pages/*`
@lines = File.read('../docs/pie-cookbook-0.9.md',:encoding=>'utf-8').split(/\n\s*/)
it = {}
toc = ["We assemble this page while transforming the remainder of the work. The work's own contents, assembled by other means, appears among the following."]

while @lines.length > 0
  line = @lines.shift
  if m = line.match(/^# +(.*)$/)
    toc << "# [[#{m[1]}]], #{ref m[1]}"
    toc << @lines[0]
    pge = it[m[1]] = []
  elsif m = line.match(/^## +(.*)$/)
    sub = m[1]
    sub = "Original #{m[1]}" if m[1] == 'Table of contents'
    toc << "[[#{sub}]], #{ref m[1]}"
    pge = it[sub] = []
  else
    pge << line
  end
end

it['Table of Contents'] = toc
it.each do |title, story|
  page title do
    story.each do |line|
      line.gsub! /\[(.*?)\]\((.*?)\)/, '[\2 \1]'
      line.gsub! /\[#.*? (.*?)\]/, '[[\1]]'
      if m = line.match(/^(#|\-|\*)/)
        markdown line
      elsif m = line.match(/^>\s*(.*)$/)
        html "<blockquote>#{m[1]}</blockquote>"
      elsif m = line.match(/^!\[(\/.*?) .*?\]/)
        html "<img src='https://raw.githubusercontent.com/WardCunningham/pie-cookbook/master/#{m[1]}' width=420>"
      else
        paragraph line
      end
    end
  end
end

`cp welcome/* pages`