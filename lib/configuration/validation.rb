require 'dry/schema'
require 'dry/validation'
require 'logger'
require_relative 'schema/s3_schema'
require_relative 'schema/postgres_schema'
require_relative 'schema/mailgun_schema'
require_relative 'schema/pushover_schema'
require_relative 'schema/discord_schema'

module Env
  class Validation
    def initialize
      @logger = Logger.new('log/ruby.log')
      @options = Env.new.options
    end

    def validate(key)
      key.each do |k|
        @logger.info("Validating #{k}")
        @logger.error("Validation failed for #{k}: #{validate_key(k).errors.to_h}") unless validate_key(k).success?
        raise validate_key(k).errors.to_h.to_s unless validate_key(k).success?
      end
    end

    private

    def validate_key(key)
      case key
      when :postgres
        Schema::PostgresSchema.new.call(@options)
      when :s3
        Schema::S3Schema.new.call(@options)
      when :mailgun
        Schema::MailgunSchema.new.call(@options)
      when :pushover
        Schema::PushoverSchema.new.call(@options)
      when :discord
        Schema::DiscordSchema.new.call(@options)
      else
        raise "Invalid key: #{key}"
      end
    end
  end
end
