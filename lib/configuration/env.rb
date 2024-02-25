require 'yaml'
require 'dry/schema'
require 'dry/validation'
require 'logger'
require_relative 'schema/s3_schema'
require_relative 'schema/postgres_schema'
require_relative 'schema/mailgun_schema'
require_relative 'schema/pushover_schema'
require_relative 'schema/discord_schema'

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

    def get
      @options
    end

    private

    def load_yaml
      @options.merge!(YAML.load(open('env.yaml')).transform_keys(&:to_sym))
    end
  end
end
