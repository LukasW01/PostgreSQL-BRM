require_relative '../configuration/env'
require_relative '../util/file'
require_relative '../notifications/hooks'
require 'pathname'
require 'logger'
require 'time'

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
      file_path = File.join(backup_folder, "#{index}_#{file_date}.sql")

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
    def reset(index)
      @logger.info('Resetting database')
      begin
        system("PGPASSWORD='#{@env[index]['password']}' dropdb -U '#{@env[index]['user']}' -h '#{@env[index]['host']}' -p '#{@env['port']}' '#{@env[index]['database']}' &> /dev/null")
        system("PGPASSWORD='#{@env[index]['password']}' createdb -U '#{@env[index]['user']}' -h '#{@env[index]['host']}' -p '#{@env['port']}' '#{@env[index]['database']}' &> /dev/null")
      rescue StandardError => e
        @hook.pg_failure
        @logger.error('Error resetting database')
        @logger.error(e.message)
        raise e
      end
      @logger.info('Database reset')
    end

    # Restore the database from a file in the file system.
    def restore(index, file_name)
      file_path = File.join(backup_folder, file_name)

      @logger.info("Restoring database from #{file_path}")
      begin
        system("PGPASSWORD='#{@env[index]['password']}' psql -U '#{@env[index]['user']}' -h '#{@env[index]['host']}' -p '#{@env['port']}' -d '#{@env[index]['database']}' -f '#{file_path}' &> /dev/null")
      rescue StandardError => e
        @hook.pg_failure
        @logger.error("Error restoring database from #{file_path}")
        @logger.error(e.message)
        raise e
      end
      @logger.info("Database restored from #{file_path}")
    end

    # List all backup files from the local backup folder.
    def list_files(index)
      Dir.glob("#{backup_folder}/*.sql")
         .reject { |f| File.directory?(f) }
         .select { |f| File.basename(f).include?(index) }
         .map { |f| Pathname.new(f).basename }
    end

    private

    def backup_folder
      @backup_folder ||= @file.app('backup_dir')
    end

    def file_date
      @file_date ||= Time.now.strftime('%Y-%m-%d-%H%M')
    end
  end
end
