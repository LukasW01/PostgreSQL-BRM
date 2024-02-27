require 'yaml'
require 'fileutils'

module Util
  class File
    def initialize
      @yaml = {}
      path_init
    end

    def event(event)
      @yaml.merge!(YAML.load(open('lib/data/event.yaml')).transform_keys(&:to_sym))[event.to_sym]
    end

    def app(info)
      @yaml.merge!(YAML.load(open('lib/data/app.yaml')).transform_keys(&:to_sym))[info.to_sym]
    end

    def path_init
      %w[lib/log lib/backup].each do |dir|
        FileUtils.mkdir_p(dir)
      end
    end
  end
end
