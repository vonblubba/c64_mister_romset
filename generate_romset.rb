# frozen_string_literal: true

require 'csv'
require 'pry'
require './lib/unzip_rom'
require './lib/process_rom'
require './lib/create_romset_structure'

CSV_PATH = [__dir__, 'data', 'sorted_games.csv'].join('/')

puts '* Generating MiSTer romset...'

create_romset_structure

CSV.foreach(CSV_PATH, headers: true, col_sep: ';') do |row|
  next if row['name'].nil? || row['filename'].nil? || !row['name'].valid_encoding? || !row['filename'].valid_encoding?

  puts "* processing game #{row['name']}"
  unzip_path = unzip_rom(game_name: row['name'], zip_path: row['filename'])
  process_rom(row: row, unzip_path: unzip_path)
end

rename_last_subfolders
