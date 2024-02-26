require_relative '../configuration/env'
require 'pathname'
require 'logger'

module Database
  class Postgres
    attr_reader :env

    def initialize
      @env = Env::Env.new.get_key(:postgres)
      @logger = logger.new('log/ruby.log')
    end

    # Backup the database and save it on the backup folder set in the
    # configuration.
    def dump
      file_path = File.join(backup_folder, "#{file_name}#{file_suffix}.sql")

      system("PGPASSWORD='#{@env['password']}' pg_dump -F p -v -O -U '#{@env['user']}' -h '#{@env['host']}' -p '#{@env['port']}' -d '#{@env['database']}' -f '#{file_path}' ")

      file_path
    end

    # Drop the database and recreate it.
    # * rake db:drop
    # * rake db:create
    def reset
      system('bundle exec rake db:drop db:create')
    end

    # Restore the database from a file in the file system.
    def restore(file_name)
      file_path = File.join(backup_folder, file_name)

      system("PGPASSWORD='#{@env['password']}' psql -U '#{@env['user']}' -h '#{@env['host']}' -p '#{@env['port']}' -d '#{@env['database']}' -f '#{file_path}'<")

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
      @backup_folder ||= Dir.mkdir(File.join(Dir.pwd, 'backup')) unless Dir.exist?(File.join(Dir.pwd, 'backup'))
    end

    def file_name
      @file_name ||= Time.current.strftime('%Y%m%d%H%M%S')
    end

    def file_suffix
      @file_suffix ||= "_#{@env['database']}"
    end
  end
end
