require 'yaml'
require 'fileutils'

module Util
  class File
    def event(event)
      YAML.load(open('lib/data/event.yaml')).then { |hash| hash.transform_keys(&:to_sym)[event.to_sym] }
    end
  end
end
