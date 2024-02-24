require 'yaml'
require 'dry-validation'

module Util
  class Configuration

    def initialize
      @options = {}
      load_yaml
    end
    
    def get_key(key)
      @options[key]
    end
    
    def get
      @options
    end

    def validate(key)
      case key
      when :postgres
        validation.db_schema.call(get_key(key)).success? ? nil : raise(ArgumentError, validation.db_schema.call(get_key(key)).errors.to_h.inspect)
      when :s3  
        validation.s3_schema.call(get_key(key)).success? ? nil : raise(ArgumentError, validation.s3_schema.call(get_key(key)).errors.to_h.inspect)
      when :discord
        validation.discord_schema.call(get_key(key)).success? ? nil : raise(ArgumentError, validation.discord_schema.call(get_key(key)).errors.to_h.inspect)
      when :pushover
        validation.pushover_schema.call(get_key(key)).success? ? nil : raise(ArgumentError, validation.pushover_schema.call(get_key(key)).errors.to_h.inspect)
      when :mailgun
        validation.mailgun_schema.call(get_key(key)).success? ? nil : raise(ArgumentError, validation.mailgun_schema.call(get_key(key)).errors.to_h.inspect)
      end
    end
    
    private

    def load_yaml
      @options.merge!(Hash[YAML::load(open("env.yaml")).map { |k, v| [k.to_sym, v] }])
    end
    
    def validation
      @validation ||= Configuration::Validation.new
    end
  end
end
