require_relative 'validation'
require 'yaml'

module Env
  class Env
    attr_reader :options

    def initialize
      @options = load_yaml
    end

    def get_key(key)
      Validation.new.validate(key)

      @options[key]
    end

    private

    def load_yaml
      ((YAML.load(open('env.yaml')) || {}).then { |hash| hash.transform_keys(&:to_sym) })
    rescue Errno::ENOENT
      raise 'No env.yaml in app root found. Take a reference from env.example.yaml'
    end
  end
end
