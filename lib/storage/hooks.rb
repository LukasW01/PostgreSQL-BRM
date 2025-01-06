require_relative '../configuration/env'
require_relative 's3'
require 'logger'

module Storage
  class Hooks
    def initialize
      @logger = Logger.new('lib/log/ruby.log')
      @env = Env::Env.new
    end

    def upload(file_path)
      @env.options[:pushover].is_a?(Hash) ? S3.new.upload(file_path) : @logger.info('S3 not configured')
    end

    def download(file_name)
      @env.options[:pushover].is_a?(Hash) ? S3.new.download(file_name) : @logger.info('S3 not configured')
    end

    def list_files(provider, index)
      case provider
      when :local
        Database::Postgres.new.list_files(index)
      when :s3
        S3.new.list_files(index)
      end
    end
  end
end
