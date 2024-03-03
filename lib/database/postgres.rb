require_relative '../configuration/env'
require_relative '../util/file'
require_relative '../notifications/hooks'
require 'pathname'
require 'logger'
require 'time'
require 'securerandom'

module Database
  class Postgres
    attr_reader :env

    def initialize
      @file = Util::File.new
      @logger = Logger.new(@file.app('log_path'))
      @env = Env::Env.new.get_key(:postgres)
      @hook = Notifications::Hooks.new
    end

    # Backup the database and save it on the backup folder set in the
    # configuration.
    def dump(index)
      file_path = File.join(backup_folder, "#{file_name}#{file_suffix(index)}.sql")

      @logger.info("Backing up database #{index}")
      begin
        system("PGPASSWORD='#{@env[index]['password']}' pg_dump -F p -v -O -U '#{@env[index]['user']}' -h '#{@env[index]['host']}' -p '#{@env[index]['port']}' -d '#{@env[index]['database']}' -f '#{file_path}' &> /dev/null")
      rescue StandardError => e
        @hook.pg_failure
        @logger.error("Error backing up database #{index}")
        @logger.error(e.message)
        raise e
      end
      @logger.info("Backup saved to #{file_path}")

      file_path
    end

    # Drop the database and recreate it.
    # * rake db:drop
    # * rake db:create
    def reset
      system('bundle exec rake db:drop db:create')
    end

    # Restore the database from a file in the file system.
    def restore(index, file_name)
      file_path = File.join(backup_folder, file_name)

      @logger.info("Restoring database from #{file_path}")
      begin
        system("PGPASSWORD='#{@env[index]['password']}' psql -U '#{@env[index]['user']}' -h '#{@env[index]['host']}' -p '#{@env['port']}' -d '#{@env[index]['database']}' -f '#{file_path}'<")
      rescue StandardError => e
        @hook.pg_failure
        @logger.error("Error restoring database from #{file_path}")
        @logger.error(e.message)
        raise e
      end
      @logger.info("Database restored from #{file_path}")

      file_path
    end

    # List all backup files from the local backup folder.
    def list_files
      Dir.glob("#{backup_folder}/*.sql")
         .reject { |f| File.directory?(f) }
         .map { |f| Pathname.new(f).basename }
    end

    private

    def backup_folder
      @backup_folder ||= @file.app('backup_dir')
    end

    def file_name
      @file_name ||= Time.now.strftime('%Y-%m-%d-%H%M')
    end

    def file_suffix(index)
      @file_suffix ||= "_#{@env[index]['database']}_#{random}"
    end

    # TODO: Add colision detection
    def random
      @random ||= SecureRandom.hex(4)
    end
  end
end
