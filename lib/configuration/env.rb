require_relative 'validation'
require 'yaml'
require 'logger'

module Env
  class Env
    attr_reader :options

    def initialize
      @options = {}
      load_yaml
    end

    def get_key(key)
      Validation.new.validate(key)
      @options[key]
    end

    def get_each_key(_key)
      @options.each_key do |_key|
        Validation.new.validate(k)
        yield k, @options[k]
      end
    end

    private

    def load_yaml
      @options.merge!(YAML.load(open('env.yaml')).transform_keys(&:to_sym))
    end
  end
end
