require_relative '../configuration/env'
require 'aws-sdk-s3'
require 'aws-sdk-s3/client'
require 'logger'
require 'fileutils'

module Storage
  class S3
    attr_reader :s3

    def initialize
      @logger = Logger.new('lib/log/ruby.log')
      @env = Env::Env.new.get_key(:s3)
      @s3 = Aws::S3::Client.new(access_key_id: @env['access_key_id'], secret_access_key: @env['secret_access_key'], endpoint: @env['endpoint'], region: @env['region'])
    end

    # Send files to S3.
    def upload(file_path)
      @logger.info("Uploading file #{file_path} to S3")
      begin
        @s3.put_object(
          bucket: @env['bucket'],
          key: file_path,
          body: File.read(file_path),
          content_type: 'application/octet-stream'
        )
      rescue StandardError => e
        @logger.error("Error uploading file #{file_path} to S3 \nERROR: #{e.message}")
        exit!
      end
    end

    # Create a local file with the contents of the remote file
    def download(file_name)
      @logger.info("Downloading file #{file_name} from S3")
      begin
        @s3.get_object(
          bucket: @env['bucket'],
          response_target: file_name,
          key: file_name
        )
      rescue StandardError => e
        @logger.error("Error downloading file #{file_name} from S3 \nERROR: #{e.message}")
        exit!
      end
    end

    # Populates a list of files stored in S3 by searching for files that include the dbname, sorting them by last_modified, and mapping them to a key/value list.
    def list_files(index)
      response = @s3.list_objects_v2(bucket: @env['bucket'])
      response[:contents]
        .select { |file| file[:key].include?(index) }
        .sort_by { |file| file[:last_modified] }
        .map { |file| { File.basename(file[:key]) => file[:key] } }
    rescue StandardError => e
      @logger.error("Error listing files in S3 \nERROR: #{e.message}")
      exit!
    end
  end
end
