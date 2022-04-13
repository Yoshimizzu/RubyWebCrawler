require 'Mechanize'
require 'csv'

class Movie < Struct.new(:title, :year, :rating, :director); end

movies = []

agent = Mechanize.new

main_page = agent.get 'http://imdb.com'
list_page = main_page.link_with(text: 'Top 250 Movies').click
rows = list_page.root.css('.lister-list tr')

rows.take(7).each do |row|
  title = row.at_css('.titleColumn a').text.strip
  rating = row.at_css('.ratingColumn strong').text.strip

  movie_page = list_page.link_with(text: title).click

  year = movie_page.root.at_css('ul[data-testid=hero-title-block__metadata] li a').text.strip
  director = movie_page.root.at_css('.ipc-metadata-list-item__content-container ul li a').text.strip

  puts "#{title}: #{rating} #{year} #{director}"

  movie = Movie.new(title, year, rating.gsub('.', ','), director)
  movies << movie
end

CSV.open('top7.csv', 'w', col_sep: ';') do |csv|
  csv << %w[Title Year Rating Director]
  movies.each do |movie|
    csv << [movie.title, movie.year, movie.rating, movie.director]
  end
end
