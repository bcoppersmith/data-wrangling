require 'nokogiri'
require 'date'
require 'curb'
require 'json'
require 'logger'
require 'open-uri'

class WikiSongPage
  attr_reader :data
  WIKI_DOMAIN = "https://en.wikipedia.org"

  def initialize(data)
    @data = data
    @wiki_doc = Nokogiri::HTML(open(WIKI_DOMAIN + @data[:link]))
  end

	def enrich
		@data[:producers] = find_producers
		@data[:title] = find_title
	end

	def valid?
		!@data[:producers].nil? && !@data[:title].nil?
	end

  def find_title
    title_text = @wiki_doc.xpath("//th[@class='summary']").first
		if title_text
			title_text.text.gsub(/(?:^"|"$)/,'')
		else
			nil
		end
  end

  def find_producers
    song_info = @wiki_doc.xpath("//table[@class='infobox vevent']/tr")
    song_info.each do |tr|
      header = tr.at_xpath("th/span/a/text()").to_s
      if header.match(/\bproducers?\b/i)
        return format_producers_text(tr) #Stop after it's found the right row
      end
    end
  end

  def format_producers_text(tr)
    value = tr.at_xpath("td").to_s
    text  = Nokogiri::HTML(value).text

    text.split(/(?:\n|, (?!Jr\.|Sr\.))/).map{ |folk| folk.strip unless folk.empty? }.compact
  end
end
