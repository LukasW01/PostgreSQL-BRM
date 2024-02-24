require_relative '../configuration/configuration'

module Database
  class Postgres

    attr_reader :configuration, :postgres
    def initialize
      @configuration = Util::Configuration.new.get_key(:postgres).verify(:password, :user, :host, :port, :database)
    end

    # Backup the database and save it on the backup folder set in the
    # configuration.
    # If you need to make the command more verbose, pass
    # `debug: true` in the arguments of the function.
    #
    # Return the full path of the backup file created in the disk.
    def dump(debug: false)
      file_path = File.join(backup_folder, "#{file_name}#{file_suffix}.sql")

      cmd = "PGPASSWORD='#{@configuration['password']}' pg_dump -F p -v -O -U '#{@configuration['user']}' -h '#{@configuration['host']}' -p '#{@configuration['port']}' -d '#{@configuration['database']}' -f '#{file_path}' "
      debug ? system(cmd) : system(cmd, err: File::NULL)

      file_path
    end

    # Drop the database and recreate it.
    #
    # This is done by invoking two Active Record's rake tasks:
    #
    # * rake db:drop
    # * rake db:create
    def reset
      system('bundle exec rake db:drop db:create')
    end

    # Restore the database from a file in the file system.
    #
    # If you need to make the command more verbose, pass
    # `debug: true` in the arguments of the function.
    def restore(file_name, debug: false)
      file_path = File.join(backup_folder, file_name)

      cmd = "PGPASSWORD='#{@configuration['password']}' psql -U '#{@configuration['user']}' -h '#{@configuration['host']}' -p '#{@configuration['port']}' -d '#{@configuration['database']}' -f '#{file_path}'<"
      debug ? system(cmd) : system(cmd, err: File::NULL)

      file_path
    end

    # List all backup files from the local backup folder.
    #
    # Return a list of strings containing only the file names.
    def list_files
      Dir.glob("#{backup_folder}/*.sql")
        .reject { |f| File.directory?(f) }
        .map { |f| Pathname.new(f).basename }
    end

    private

    def file_name
      @file_name ||= Time.current.strftime('%Y%m%d%H%M%S')
    end

    def file_suffix
      @file_suffix ||= "_#{@configuration['database']}"
    end

    def backup_folder
      @backup_folder ||= begin
        File.join(Rails.root, "backup").tap do |folder|
          FileUtils.mkdir_p(folder)
        end
      end
    end

  end
end
