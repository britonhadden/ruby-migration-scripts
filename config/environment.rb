require 'mongoid'
TOOLS_ROOT_PATH = '/home/mike/migration/'
Mongoid.load!(File.join(TOOLS_ROOT_PATH,'config','mongoid.yml'))

models_dir = Dir.new(File.join(TOOLS_ROOT_PATH, 'mongoid') )
models_dir.each do |model|
    if model.split(".")[1] == "rb"
          require File.join(models_dir.path, model)
    end
end


