require_relative '../configuration/env'
require 'aws-sdk-s3'
require 'aws-sdk-s3/client'
require 'logger'
require 'fileutils'
require 'pathname'

module Storage
  class S3
    attr_reader :env, :s3

    def initialize
      @env = Env::Env.new.get_key(:s3)
      @s3 = Aws::S3::Client.new(
        access_key_id: @env['access_key_id'], secret_access_key: @env['secret_access_key'],
        endpoint: @env['endpoint'],
        region: @env['region']
      )
      @logger = Logger.new('log/ruby.log')
    end

    # Send files to S3.
    def upload(file_path)
      file_name = Pathname.new(file_path).basename

      @logger.info("Uploading file #{file_name} to S3")
      begin
        @s3.put_object(
          key: file_name.to_s,
          body: File.read(file_path),
          bucket: @env['bucket'],
          content_type: 'application/octet-stream'
        )
      rescue StandardError => e
        @logger.error("Error uploading file #{file_name} to S3")
        @logger.error(e.message)
        raise e
      end
    end

    # Create a local file with the contents of the remote file. (throws error)
    def download(file_name)
      puts backup_folder
      file_path = File.join(backup_folder || '', file_name)

      @logger.info("Downloading file #{file_name} from S3")
      begin
        @s3.get_object(
          response_target: file_path,
          bucket: @env['bucket'],
          key: file_name
        )
      rescue StandardError => e
        @logger.error("Error downloading file #{file_name} from S3")
        @logger.error(e.message)
        raise e
      end
    end

    private

    # Force UTF-8 encoding in the file body.
    def file_body(file)
      file.body.force_encoding('UTF-8')
    end

    # Create a backup folder if it doesn't exist.
    def backup_folder
      @backup_folder ||= Dir.mkdir(File.join(Dir.pwd, 'backup')) unless Dir.exist?(File.join(Dir.pwd, 'backup'))
    end
  end
end
