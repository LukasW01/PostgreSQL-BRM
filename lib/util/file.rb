require 'yaml'

module Util
  class File
    def initialize
      @yaml = {}
    end

    def event(event)
      @yaml.merge!(YAML.load(open('data/event.yaml')).transform_keys(&:to_sym))[event.to_sym]
    end

    def app(info)
      @yaml.merge!(YAML.load(open('data/app.yaml')).transform_keys(&:to_sym))[info.to_sym]
    end
  end
end
