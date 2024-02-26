require_relative '../configuration/env'
require 'aws-sdk-s3'
require 'aws-sdk-s3/client'
require 'logger'
require 'fileutils'

module Storage
  class S3
    attr_reader :env, :s3

    def initialize
      @logger = Logger.new('log/ruby.log')
      @env = Env::Env.new.get_key(:s3)
      @s3 = Aws::S3::Client.new(
        access_key_id: @env['access_key_id'], secret_access_key: @env['secret_access_key'],
        endpoint: @env['endpoint'],
        region: @env['region']
      )
    end

    # Send files to S3.
    def upload(file_path)
      @logger.info("Uploading file #{file_path} to S3")
      begin
        @s3.put_object(
          key: file_path.to_s,
          body: File.read(file_path),
          bucket: @env['bucket'],
          content_type: 'application/octet-stream'
        )
      rescue StandardError => e
        @logger.error("Error uploading file #{file_path} to S3")
        @logger.error(e.message)
        raise e
      end
      @logger.info("File #{file_path} uploaded to S3")
    end

    # Create a local file with the contents of the remote file
    def download(file_name)
      @logger.info("Downloading file #{file_name} from S3")
      begin
        @s3.get_object(
          response_target: "backup/#{file_name}",
          bucket: @env['bucket'],
          key: file_name
        )
      rescue StandardError => e
        @logger.error("Error downloading file #{file_name} from S3")
        @logger.error(e.message)
        raise e
      end
      @logger.info("File #{file_name} downloaded from S3")
    end

    def list_s3_files
      @logger.info('Listing files in S3')
      begin
        puts @s3.list_objects_v2(
          bucket: @env['bucket']
        )
      rescue StandardError => e
        @logger.error('Error listing files in S3')
        @logger.error(e.message)
        raise e
      end
    end

    private

    # Force UTF-8 encoding in the file body.
    def file_body(file)
      file.body.force_encoding('UTF-8')
    end
  end
end
