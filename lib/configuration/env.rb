require 'yaml'
require 'dry/schema'
require 'dry/validation'
require 'logger'
require_relative 'schema/s3_schema'
require_relative 'schema/postgres_schema'
require_relative 'schema/mailgun_schema'
require_relative 'schema/pushover_schema'
require_relative 'schema/discord_schema'

class Env
  attr_reader :options

  def initialize
    @logger = Logger.new('log/ruby.log')
    @options = {}
    load_yaml
  end

  def get_key(key)
    validate([key])
    @options[key]
  end

  def validate(key)
    key.each do |k|
      @logger.info("Getting key: #{k}")
      @logger.error("Validation failed for #{k}: #{validate_key(k).errors.to_h}") unless validate_key(k).success?
      raise validate_key(k).errors.to_h.to_s unless validate_key(k).success?
    end
  end

  private

  def load_yaml
    @options.merge!(YAML.load(open('env.yaml')).transform_keys(&:to_sym))
  end

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
