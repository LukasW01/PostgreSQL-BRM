require 'yaml'
require 'logger'
require_relative 'validation'

module Env
  class Env
    attr_reader :options

    def initialize
      @options = {}
      load_yaml
    end

    def get_key(key)
      Validation.new.validate([key])
      @options[key]
    end

    private

    def load_yaml
      @options.merge!(YAML.load(open('env.yaml')).transform_keys(&:to_sym))
    end
  end
end
