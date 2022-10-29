# frozen_string_literal: true

def process_roms(game_name:, unzip_path:, game_folder:)
  romset_path = [__dir__, '..', 'generated_romset', 'games', letter(game_name: game_name)].join('/')
  FileUtils.mkdir_p(romset_path) unless File.directory?(romset_path)

  destination_folder = [romset_path, rom_name(game_name: game_name)].join('/')
  FileUtils.mkdir_p(destination_folder) unless File.directory?(destination_folder)

  Dir["#{unzip_path}/*.{T64,D64,TAP,G64,t64,d64,tap,g64}"].each do |filename|
    FileUtils.cp(filename, [destination_folder, File.basename(filename)].join('/'))
    puts "* copied rom #{rom_name(game_name: game_name)} to destination"
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
