#!/usr/bin/env ruby

require "tmpdir"
require "fileutils"
require "json"

q = ARGV[0]
if q.to_s.size == 0
  puts "Usage: #{__FILE__} [QUERY]"
  exit 1
end

Dir.mktmpdir do |dir|
  puts "working in #{dir}"
  Dir.chdir dir

  files = `rmapi find / #{q}`.split("\n").map{|x| x[3..-1]}.map(&:strip)
  files.each.with_index do |f, i|
    puts "#{i} - #{f}"
  end

  print ">> "
  index = STDIN.gets.to_i
  if index < 0 || index >= files.size
    puts "bad index"
    exit 1
  end

  path = files[index]
  `rmapi get "#{path}"`
  `unzip "#{File.join("./", path)}"`

  all = []
  paths = Dir["./*highlights/*.json"]
  contents = paths.map{|f| JSON.parse(File.read(f)) }
  contents.each do |c|
    c["highlights"].each do |hs|
      hs.each do |h|
        all << [h["start"], h["text"]]
      end
    end
  end

  all.sort_by{|(s, t)| s}.each do |h|
    puts h[1]
    puts
  end
end
