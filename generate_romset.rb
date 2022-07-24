# frozen_string_literal: true

require 'csv'
require 'pry'
require './lib/unzip_rom'
require './lib/process_roms'

CSV_PATH = [__dir__, 'data', 'games.csv'].join('/')

puts '* Generating MiSTer romset...'

CSV.foreach(CSV_PATH, headers: true, col_sep: ';') do |row|
  puts "* processing game #{row['name']}"
  unzip_path = unzip_rom(game_name: row['name'], zip_path: row['filename'])
  process_roms(game_name: row['name'], unzip_path: unzip_path)
end
