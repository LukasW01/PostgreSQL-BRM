require 'yaml'

module Util
  class File
    def initialize
      @yaml = {}
      path_init
      copy_example_env
    end

    def event(event)
      @yaml.merge!(YAML.load(open('data/event.yaml')).transform_keys(&:to_sym))[event.to_sym]
    end

    def app(info)
      @yaml.merge!(YAML.load(open('data/app.yaml')).transform_keys(&:to_sym))[info.to_sym]
    end

    def path_init
      %w[log backup].each do |dir|
        FileUtils.mkdir_p(dir)
      end
    end
  end
end
