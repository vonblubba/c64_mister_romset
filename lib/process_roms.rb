# frozen_string_literal: true

MAX_FILES_IN_FOLDER = 200

def process_roms(row:, unzip_path:)
  FileUtils.mkdir_p(romset_path) unless File.directory?(romset_path)
  FileUtils.mkdir_p(letter_path(row: row)) unless File.directory?(letter_path(row: row))
  destination_folder = destination_folder(row: row)
  FileUtils.mkdir_p(destination_folder) unless File.directory?(destination_folder)

  Dir["#{unzip_path}/*.{T64,D64,TAP,G64,t64,d64,tap,g64}"].each do |filename|
    FileUtils.cp(filename, [destination_folder, File.basename(filename)].join('/'))
    puts "* copied rom #{rom_name(game_name: game_name(row))} to destination #{destination_folder}"
  end
end

def letter(game_name:)
  first_letter = game_name[0].capitalize
  first_letter = '#' unless [*'a'..'z', *'A'..'Z'].include?(first_letter)
  first_letter
end

def valid_folder_name(folder_name:)
  folder_name.gsub(/[\x00\/\\:\*\?\"<>\|;'\[\]]/, '').encode(
    Encoding.find('ASCII'),
    invalid: :replace,
    undef: :replace,
    replace: '',
    universal_newline: true
  )
end

def rom_name(game_name:)
  valid_folder_name(folder_name: "#{game_name.split(/ |\_/).map(&:capitalize).join(" ")}")
end

def new_subfolder_name(game_name:)
  valid_folder_name(folder_name: game_name.gsub(' ', '')[0..3].downcase)
end

def romset_path
  [__dir__, '..', 'generated_romset', 'games'].join('/')
end

def letter_path(row:)
  [__dir__, '..', 'generated_romset', 'games', letter(game_name: game_name(row))].join('/')
end

def destination_folder(row:)
  if current_subfolder.nil? || needs_new_folder?
    new_subfolder = [current_letter_folder, new_subfolder_name(game_name: game_name(row)), rom_name(game_name: game_name(row))].join('/')
    FileUtils.mkdir_p(new_subfolder) unless File.directory?(new_subfolder)
    new_subfolder
  else
    [current_letter_folder, current_subfolder, rom_name(game_name: game_name(row))].join('/')
  end
end

def needs_new_folder?
  Dir[File.join([current_letter_folder, current_subfolder].join('/'), '*')].count { |file| !File.file?(file) } > MAX_FILES_IN_FOLDER
end

def current_subfolder
  letter_folder = Dir.entries(romset_path).reject{ |entry| entry == "." || entry == ".." }.sort.last
  Dir.entries([romset_path, letter_folder].join('/')).reject{ |entry| entry == "." || entry == ".." }.sort.last
end

def current_letter_folder
  [romset_path, Dir.entries(romset_path).reject{ |entry| entry == "." || entry == ".." }.sort.last].join('/')
end

def game_name(row)
  row['name']
end
