require_relative '../configuration/env'
require_relative '../notifications/hooks'
require 'pathname'
require 'logger'
require 'time'
require 'open3'

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
      stdout, stderr, status = Open3.capture3("PGPASSWORD='#{@env[index]['password']}' pg_dump -Fc -v -O -U '#{@env[index]['user']}' -h '#{@env[index]['host']}' -p '#{@env[index]['port']}' -d '#{@env[index]['database']}' -f '#{file_path}'")
      unless status.success?
        @logger.error("Error backing up database #{index} \nSTDOUT: #{stdout}\nSTDERR: #{stderr}")
        @hook.send(:error)
        exit!
      end

      file_path
    end

    # Drop the database and recreate it.
    def reset(index)
      @logger.info('Resetting database')
      stdout, stderr, status = Open3.capture3("PGPASSWORD='#{@env[index]['password']}' dropdb -U '#{@env[index]['user']}' -h '#{@env[index]['host']}' -p '#{@env[index]['port']}' '#{@env[index]['database']}'")
      unless status.success?
        @logger.error("Error dropping database '#{index}' \nSTDOUT: #{stdout}\nSTDERR: #{stderr}")
        @hook.send(:error)
        exit!
      end

      stdout, stderr, status = Open3.capture3("PGPASSWORD='#{@env[index]['password']}' createdb -U '#{@env[index]['user']}' -h '#{@env[index]['host']}' -p '#{@env[index]['port']}' '#{@env[index]['database']}'")
      unless status.success?
        @logger.error("Error creating database '#{index}' \nSTDOUT: #{stdout}\nSTDERR: #{stderr}")
        @hook.send(:error)
        exit!
      end
    end

    # Restore the database from a file in the file system.
    def restore(index, file_path)
      @logger.info("Restoring database from file: '#{file_path}'")
      stdout, stderr, status = Open3.capture3("PGPASSWORD='#{@env[index]['password']}' pg_restore -U '#{@env[index]['user']}' -h '#{@env[index]['host']}' -p '#{@env[index]['port']}' -d '#{@env[index]['database']}' '#{file_path}'")
      unless status.success?
        @logger.error("Error restoring database #{index} \nSTDOUT: #{stdout}\nSTDERR: #{stderr}")
        @hook.send(:error)
        exit!
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
