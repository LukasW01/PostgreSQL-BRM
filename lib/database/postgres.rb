require_relative '../configuration/env'
require_relative '../notifications/hooks'
require 'pathname'
require 'logger'
require 'time'

module Database
  class Postgres
    def initialize
      @logger = Logger.new('lib/log/ruby.log')
      @env = Env::Env.new.get_key(:postgres)
      @hook = Notifications::Hooks.new
    end

    # Backup the database and save it on the backup folder set in the configuration.
    def dump(index)
      file_path = File.join('lib/backup', "#{index}_#{file_date}.sql")

      @logger.info("Backing up database #{index}")
      begin
        system("PGPASSWORD='#{@env[index]['password']}' pg_dump -F p -v -O -U '#{@env[index]['user']}' -h '#{@env[index]['host']}' -p '#{@env[index]['port']}' -d '#{@env[index]['database']}' -f '#{file_path}' &> /dev/null")
      rescue StandardError => e
        @hook.send(:error)
        @logger.error("Error backing up database #{index}")
        @logger.error(e.message)
        raise e
      end

      if File.exist?(file_path)
        @logger.info("Database #{index} backed up to #{file_path}")
      else
        @hook.send(:error)
        @logger.error("Error saving database #{index}. Backup file #{file_path} was not found due to an error while saving")
        @logger.error("Possible root cause: Connection interrupted/missing write permissions.")
        raise 'Error backing up database. Backup file not found due to an error when backing up'
      end

      file_path
    end

    # Drop the database and recreate it.
    def reset(index)
      @logger.info('Resetting database')
      begin
        system("PGPASSWORD='#{@env[index]['password']}' dropdb -U '#{@env[index]['user']}' -h '#{@env[index]['host']}' -p '#{@env['port']}' '#{@env[index]['database']}' &> /dev/null")
        system("PGPASSWORD='#{@env[index]['password']}' createdb -U '#{@env[index]['user']}' -h '#{@env[index]['host']}' -p '#{@env['port']}' '#{@env[index]['database']}' &> /dev/null")
      rescue StandardError => e
        @hook.send(:error)
        @logger.error('Error resetting database')
        @logger.error(e.message)
        raise e
      end
    end

    # Restore the database from a file in the file system.
    def restore(index, file_name)
      file_path = File.join('lib/backup', file_name)

      @logger.info("Restoring database from #{file_path}")
      begin
        system("PGPASSWORD='#{@env[index]['password']}' psql -U '#{@env[index]['user']}' -h '#{@env[index]['host']}' -p '#{@env['port']}' -d '#{@env[index]['database']}' -f '#{file_path}' &> /dev/null")
      rescue StandardError => e
        @hook.send(:error)
        @logger.error("Error restoring database from #{file_path}")
        @logger.error(e.message)
        raise e
      end
    end

    # List all backup files from the local backup folder.
    def list_files(index)
      Dir.glob('lib/backup/*.sql')
         .reject { |f| File.directory?(f) }
         .select { |f| File.basename(f).include?(index) }
         .map { |f| Pathname.new(f).basename }
    end

    private

    def file_date
      @file_date ||= Time.now.strftime('%Y-%m-%d-%H%M')
    end
  end
end
