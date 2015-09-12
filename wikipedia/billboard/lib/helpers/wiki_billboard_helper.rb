module BillboardParser

  module WikiBillboardHelper
    extend self

    def get_songs(doc)
      rows = doc.css("div.mw-content-ltr table.wikitable tr")
      rows.map { |tr| parse_row(tr) }.compact
    end

    def parse_row(tr)
      offset = is_a_date?(tr.css("td[1]").text) ? 1 : 0

      song = {}
      song[:link]   = tr.css("td[#{1+offset}] a").map { |link| link["href"] if link["href"].match(/^\/wiki/)}.first
      song[:artist] = tr.css("td[#{2+offset}]").text.gsub(/ featuring .*$/, "")

      song unless song.any? { |key, value| value.nil? }
    end

    def is_a_date?(text)
      month_regex = "(?:January|February|March|April|May|June|July|August|September|October|November|December)"
      !!text.match(/^#{month_regex}\s\d{1,2}$/)
    end

  end

end
