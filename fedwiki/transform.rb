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
  lines = text.split /(\r?\n)+/m
  lines.each do |line|
    line.gsub! /```(.+?)```/, '<b>\1</b>'
    line.gsub! /`(.+?)`/, '<b>\1</b>'
    line.gsub! /https?:\/\/\S+/, '[\0 \0]'
    line.gsub! /WardCunningham\/\S+?#\d+/, '[https://github.com/\0 \0]'
    line.gsub! /([0-9a-f]{7})[0-9a-f]{9,}/, '[https://github.com/wardcunningham/wiki/commit/\0 \1]'
    line.gsub! /##+/, '<h3>'
    paragraph line unless line[0,1] == '>'
  end
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

`rm pages/*`
@lines = File.read('../docs/pie-cookbook-0.9.md',:encoding=>'utf-8').split(/\n\s*/)
it = {}
syn = "We assemble this page while transforming the remainder of the work. The work's own contents, assembled by other means, appears among the following."
toc = it['Table of Contents'] = [syn]
while @lines.length > 0
  line = @lines.shift
  if m = line.match(/^(#) (.*)$/)
    toc << "[[#{m[2]}]]"
    pge = it[m[2]] = []
  else
    pge << line
  end
end

it.each do |title, story|
  puts title
  page title do
    story.each do |line|
      paragraph line
    end
  end
end