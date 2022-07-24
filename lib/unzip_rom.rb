# frozen_string_literal: true

require 'zip'

MAX_SIZE = 4096**2 # 1MiB (but of course you can increase this)

def unzip_rom(game_name:, zip_path:)
  return false if zip_path.nil? || game_name.nil?

  zip_file_path = [__dir__, '..', 'data', 'Games', zip_path.gsub('\\', '/')].join('/')
  puts "* unzipping file #{zip_file_path}"

  unless File.exist? zip_file_path
    puts "* ERROR: file #{zip_file_path} does not exits"
    return false
  end

  unzip_folder = zip_file_path.chomp('.zip').chomp('.ZIP')

  Zip::File.open(zip_file_path) do |zip_file|
    zip_file.each do |entry|
      raise 'File too large when extracted' if entry.size > MAX_SIZE

      entry_path = [File.dirname(zip_file_path), File.basename(zip_file_path, File.extname(zip_file_path)), entry.name].join('/')

      FileUtils.mkdir_p(unzip_folder) unless File.directory?(unzip_folder)
      zip_file.extract(entry, entry_path) unless File.exist?(entry_path)
      puts "* extracted #{entry.name} from #{zip_file}"
    end
  end

  unzip_folder
end
