require_relative 'env'
require_relative '../util/file'
require_relative 'schema/s3_schema'
require_relative 'schema/postgres_schema'
require_relative 'schema/crypt_schema'
require_relative 'schema/mailgun_schema'
require_relative 'schema/pushover_schema'
require_relative 'schema/discord_schema'
require 'dry/schema'
require 'dry/validation'
require 'logger'

module Env
  class Validation
    def initialize
      @logger = Logger.new('lib/log/ruby.log')
      @env = Env.new
    end

    def validate(key)
      @logger.info("Request and validate '#{key}'")
      @logger.error("Validation failed for '#{key}': #{validate_key(key).errors.to_h}") unless validate_key(key).success?
      raise validate_key(key).errors.to_h.to_s unless validate_key(key).success?

      @logger.info("Validation passed for '#{key}'")
    end

    private

    def validate_key(key)
      case key
      when :postgres
        Schema::PostgresSchema.new.call(@env.options)
      when :crypt
        Schema::CryptSchema.new.call(@env.options)
      when :s3
        Schema::S3Schema.new.call(@env.options)
      when :mailgun
        Schema::MailgunSchema.new.call(@env.options)
      when :pushover
        Schema::PushoverSchema.new.call(@env.options)
      when :discord
        Schema::DiscordSchema.new.call(@env.options)
      else
        raise "Invalid key: '#{key}'"
      end
    end
  end
end
