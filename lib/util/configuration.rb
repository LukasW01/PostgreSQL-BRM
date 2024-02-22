require_relative '../hooks'

module Util
  class Configuration

    def initialize()
      @options = {}
      load_yaml
    end
    
    def load_yaml
      @options.merge!(Hash[YAML::load(open("env.yaml")).map { |k, v| [k.to_sym, v] }])
    end
    
    def get(key)
      @options[key]
    end
  end
end
