require "json"
require "nokogiri"
require "logger"
require "open-uri"
require "optparse"
require_relative "helpers/wiki_song_page"
require_relative "helpers/wiki_billboard_helper"
include BillboardParser

options = {}
option_parser = OptionParser.new do |opts|
  opts.on("-d", "--debug", "Log debug statements to stderr") do |debug|
    options[:debug] = debug
  end
end
option_parser.parse!

@log = Logger.new($stderr)
@log.progname = "billboard_hot_100_parser"
@log.level =   
  if options[:debug]
    Logger::DEBUG
  else
    Logger::INFO
  end

TOP_10_URL_PREFIX = "https://en.wikipedia.org/wiki/List_of_Billboard_Hot_100_top_10_singles_in_"
START_YEAR = "1958"
END_YEAR = "2015"

(START_YEAR..END_YEAR).each do |year|
  url = TOP_10_URL_PREFIX + year
  @log.debug "grabbing data for #{year}"

  page  = Nokogiri::HTML(open(url))
  songs = WikiBillboardHelper.get_songs(page)

  all_songs = {year: year, songs: []}
  
  songs.each do |song_info|
    @log.debug "enriching data for #{song_info[:link]}"
    song = WikiSongPage.new(song_info)
    song.enrich
    all_songs[:songs] << song.data if song.valid?
  end

  puts JSON.generate(all_songs)
end
