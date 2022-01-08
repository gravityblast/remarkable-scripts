#!/usr/bin/env ruby

require "tmpdir"
require "fileutils"
require "json"

q = ARGV[0]
if q.to_s.size == 0
  STDERR.puts "Usage: #{__FILE__} [QUERY]"
  exit 1
end

Dir.mktmpdir do |dir|
  STDERR.puts "working in #{dir}"
  Dir.chdir dir

  files = `rmapi find / #{q}`.split("\n").map{|x| x[3..-1]}.map(&:strip)
  files.each.with_index do |f, i|
    STDERR.puts "#{i} - #{f}"
  end

  STDERR.print ">> "
  index = STDIN.gets.to_i
  if index < 0 || index >= files.size
    STDERR.puts "bad index"
    exit 1
  end

  path = files[index]
  `rmapi get "#{path}"`
  `unzip "#{File.join("./", path)}"`

  pages = JSON.parse(File.read(Dir["./*.content"].first))["pages"]

  all = []
  paths = Dir["./*highlights/*.json"]
  paths.each do |path|
    page_id = path.match(/([^\/]+)\.json$/)[1]
    page = pages.index(page_id)

    content = JSON.parse(File.read(path))
    content["highlights"].each do |hs|
      hs.each do |h|
        all << {
          page: page + 1,
          start: h["start"],
          text: h["text"]
        }
      end
    end
  end

  current_page = 0
  all.sort_by{|h| [h[:page], h[:start]]}.each do |h|
    if h[:page] != current_page
      puts
      current_page = h[:page]
      puts "Page #{current_page}"
      puts
    end
    puts h[:text]
  end
end
