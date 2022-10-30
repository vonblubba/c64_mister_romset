# frozen_string_literal: true

MAX_FILES_IN_FOLDER = 200

def process_rom(row:, unzip_path:)
  FileUtils.mkdir_p(absolute_romset_path) unless File.directory?(absolute_romset_path)
  FileUtils.mkdir_p(absolute_game_letter_path(row: row)) unless File.directory?(absolute_game_letter_path(row: row))
  destination_folder = destination_folder_absolute_path(row: row)
  FileUtils.mkdir_p(destination_folder) unless File.directory?(destination_folder)

  Dir["#{unzip_path}/*.{T64,D64,TAP,G64,t64,d64,tap,g64}"].each do |filename|
    FileUtils.cp(filename, [destination_folder, File.basename(filename)].join('/'))
    puts "* copied rom #{sanitized_game_name(row: row)} to destination #{destination_folder}"
  end
end

# Path helpers
def absolute_path(relative_path:)
  [__dir__, '..', 'generated_romset', 'games', relative_path].join('/')
end

def absolute_romset_path
  [__dir__, '..', 'generated_romset', 'games'].join('/')
end

def absolute_game_letter_path(row:)
  [__dir__, '..', 'generated_romset', 'games', game_letter_path(row: row)].join('/')
end

def game_letter_path(row:)
  first_letter = row['name'][0].capitalize
  first_letter = '#' unless [*'a'..'z', *'A'..'Z'].include?(first_letter)
  first_letter
end

# Current paths
def current_subfolder_absolute_path
  current_subfolder = Dir.entries(current_letter_absolute_path).reject { |e| ['.', '..'].include? e }.sort.last
  [current_letter_absolute_path, current_subfolder].join('/')
end

def current_letter_absolute_path
  [absolute_romset_path, Dir.entries(absolute_romset_path).reject { |e| ['.', '..'].include? e }.sort.last].join('/')
end

def last_game_in_current_subfolder
  return nil unless current_subfolder_absolute_path

  last_game = Dir.entries(current_subfolder_absolute_path).reject { |e| ['.', '..'].include? e }.sort.last
  last_game ? sanitized_folder_name(folder_name: last_game).gsub(' ', '').gsub('-', '')[0..3].upcase : nil
end

# Sanitizers
def sanitized_folder_name(folder_name:)
  folder_name.gsub(/[\x00\/\\:\*\?\"<>\|;'\[\]]/, '').encode(
    Encoding.find('ASCII'),
    invalid: :replace,
    undef: :replace,
    replace: '',
    universal_newline: true
  )
end

def sanitized_game_name(row:)
  sanitized_folder_name(folder_name: "#{row['name'].split(/ |\_/).map(&:capitalize).join(" ")}")
end

# Calculators
def new_subfolder_name(row:)
  new_subfolder = shortened_game_name(row: row)
  range_end = last_game_in_current_subfolder

  FileUtils.mv current_subfolder_absolute_path, [current_subfolder_absolute_path, new_subfolder].join(' - ') if range_end
  new_subfolder
end

def destination_folder_absolute_path(row:)
  if current_subfolder_absolute_path.nil? || needs_new_folder?
    [current_letter_absolute_path, new_subfolder_name(row: row), sanitized_game_name(row: row)].join('/')
  else
    [current_subfolder_absolute_path, sanitized_game_name(row: row)].join('/')
  end
end

def needs_new_folder?
  Dir[File.join(current_subfolder_absolute_path, '*')].count { |file| !File.file?(file) } >= MAX_FILES_IN_FOLDER
end

def shortened_game_name(row:)
  sanitized_game_name(row: row).gsub(' ', '').gsub('-', '')[0..3].upcase
end
