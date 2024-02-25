require 'yaml'
require 'dry/schema'
require 'dry/validation'
require_relative 'schema/s3_schema'
require_relative 'schema/postgres_schema'
require_relative 'schema/mailgun_schema'
require_relative 'schema/pushover_schema'
require_relative 'schema/discord_schema'

class Env

  def initialize
    @options = {}
    load_yaml
  end
  
  def get_key(key)
    raise validation(key).errors.to_h.to_s unless validation(key).success?
    @options[key]
  end
  
  private

  def load_yaml
    @options.merge!(Hash[YAML::load(open("env.yaml")).map { |k, v| [k.to_sym, v] }])
  end

  def validation(key)
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
    end
  end
end

