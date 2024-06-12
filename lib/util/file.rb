require 'yaml'
require 'fileutils'

module Util
  class File
    def initialize
      path_init
    end

    def event(event)
      YAML.load(open('lib/data/event.yaml')).then { |hash| hash.transform_keys(&:to_sym)[event.to_sym] }
    end

    def path_init
      %w[lib/log lib/backup].each do |dir|
        FileUtils.mkdir_p(dir)
      end
    end
  end
end
