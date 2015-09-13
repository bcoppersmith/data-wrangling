require 'json'

puts %w(
        year
        percent_of_songs_by_top_artists
        percent_of_songs_by_top_producers
        count
        count_of_songs_by_top_artists
        count_of_songs_by_top_producers
       ).join("\t")

STDIN.each do |line|
  input = JSON.parse(line)

  artists   = Hash.new { |h, k| h[k] = [] }
  producers = Hash.new { |h, k| h[k] = [] }
  songs     = input['songs']
  count     = songs.length
  year      = input['year']

  songs.each do |song|
    song['producers'].map { |prod| producers[prod] << song['title'] unless prod == song['artist']}
    artists[song['artist']] << song['title']
  end

  top_10_percent_artists = (artists.keys.length * 0.1).floor
  top_artists = artists.sort_by { |artist, songs| songs.length }.reverse.take(top_10_percent_artists)
  artist_song_count = top_artists.map { |element| element.last.count }.reduce(:+)

  top_10_percent_producers = (producers.keys.length * 0.1).floor
  top_producers = producers.sort_by { |producer, songs| songs.length }.reverse.take(top_10_percent_producers)
  producer_song_count = top_producers.map { |element| element.last.count}.reduce(:+)

  puts [year, 
        artist_song_count.to_f / count,
        producer_song_count.to_f / count,
        count,
        artist_song_count,
        producer_song_count
       ].join("\t")
end
