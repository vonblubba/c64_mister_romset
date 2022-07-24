# frozen_string_literal: true

def create_romset_structure
  local_path = [__dir__, '..', 'generated_romset'].join('/')
  games_folder = [local_path, 'games'].join('/')
  demo_folder = [local_path, 'demo'].join('/')
  utils_folder = [local_path, 'utils'].join('/')
  cracktro_folder = [local_path, 'cracktro'].join('/')

  FileUtils.remove_dir(local_path)
  FileUtils.mkdir_p(local_path) unless File.directory?(local_path)

  [games_folder, demo_folder, cracktro_folder, utils_folder].map do |folder|
    FileUtils.mkdir_p(folder) unless File.directory?(folder)
  end

  FileUtils.mkdir_p([games_folder, '#'].join('/'))
  ('A'..'Z').map { |letter| FileUtils.mkdir_p([games_folder, letter].join('/')) unless File.directory?([games_folder, letter].join('/')) }
end
