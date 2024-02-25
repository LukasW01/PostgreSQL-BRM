require_relative '../configuration/env'
require 'aws-sdk-s3'
require 'aws-sdk-s3/client'
require 'logger'
require 'fileutils'
require 'pathname'

module Storage
  class S3
    attr_reader :configuration, :s3

    def initialize
      @configuration = Env.new.get_key(:s3)
      @s3 = Aws::S3::Client.new(
        access_key_id: configuration['access_key_id'],
        secret_access_key: configuration['secret_access_key'],
        endpoint: configuration['endpoint'],
        region: configuration['region'],
      )
      @logger = Logger.new('log/ruby.log')
    end

    # Send files to S3.
    def upload(file_path, tags = '')
      file_name = Pathname.new(file_path).basename

      @logger.info("Uploading file #{file_name} to S3")
      begin
      @s3.put_object(
          key: file_name.to_s,
          body: IO.read(file_path),
          bucket: configuration['bucket'],
          content_type: "application/octet-stream",
      )
      rescue StandardError => e
        @logger.error("Error uploading file #{file_name} to S3")
        @logger.error(e.message)
        raise e
      end
    end

    # Create a local file with the contents of the remote file.
    def download(file_name)

    end

    # List all the files in the bucket's remote path. The result
    # is sorted in the reverse order, the most recent file will
    # show up first.
    #
    # Return an array of strings, containing only the file name.
    def list_files
      files = remote_directory.files.map { |file| file.key }

      # The first item in the array is only the path an can be discarded.
      files = files.slice(1, files.length - 1) || []

      files
        .map { |file| Pathname.new(file).basename.to_s }
        .sort
        .reverse
    end

    private

    # Force UTF-8 encoding in the file body.
    def file_body(file)
      file.body.force_encoding('UTF-8')
    end

    # Make sure the path exists and that there are no files with
    # the same name of the one that is being downloaded.
    def prepare_local_folder(local_file_path)
      FileUtils.mkdir_p("backup")
      File.delete(local_file_path) if File.exist?(local_file_path)
    end

    def create_local_file(local_file_path, file_from_storage)
      File.open(local_file_path, 'w') do |local_file|
        body = file_body(file_from_storage)
        local_file.write(body)
      end
    end
  end
end
