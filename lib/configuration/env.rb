require 'yaml'
require 'dry-validation'

module Env
  class Env

    def initialize
      @options = {}
      load_yaml
    end
    
    def get_key(key)
      @options[key]
    end

    private

    def load_yaml
      @options.merge!(Hash[YAML::load(open("env.yaml")).map { |k, v| [k.to_sym, v] }])
    end
  end
end
