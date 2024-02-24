require_relative '../util/terminal'
require_relative '../database/postgres'
require_relative '../storage/s3'
require_relative '../notifications/discord'
require_relative '../notifications/pushover'
require_relative '../notifications/mailgun'
require 'tty-prompt'
require 'tty-spinner'
require 'pastel'

namespace :postgresql_backup do
  desc 'Dumps the database'
  task :dump do
    title = pastel.yellow.bold('POSTGRESQL DATABASE BACKUP')
    terminal.box(title)
    disclaimer.show(title: title, texts: configuration_to_text)

    file_path = Util::Terminal.spinner('Backing up database') { db.dump }

    if configuration.s3?
      Util::Terminal.spinner('Uploading file') { storage.upload(file_path) }
      Util::Terminal.spinner('Deleting local file') { File.delete(file_path) } if File.exist?(file_path)
    end

    puts ''
    puts pastel.green('All done.')
  end

  desc 'Restores a database backup into the database'
  task :restore do
    title = pastel.green('POSTGRESQL DATABASE RESTORE')
    disclaimer.show(title: title, texts: configuration_to_text)
    
    
    local_file_path = ''
    files = Util::Terminal.spinner('Loading backups list') { list_backup_files }

    if files.present?
      puts ''
      file_name = prompt.select('Choose the file to restore', files)
      puts ''

      local_file_path = Util::Terminal.spinner('Downloading file') { storage.download(file_name) } if configuration.s3?

      db.reset

      Util::Terminal.spinner('Restoring data') { db.restore(file_name) }

      Util::Terminal.spinner('Deleting local file') { File.delete(local_file_path) } if configuration.s3?

      puts ''
      puts pastel.green('All done.')
    else
      spinner = TTY::Spinner.new("#{pastel.yellow('[:spinner] ')}Restoring data...")
      error_message = "#{pastel.red.bold('failed')}. Backup files not found."
      spinner.success(error_message)
    end
  end

  desc 'Lists all defined configurations'
  task :config do
    title = pastel.yellow.bold('POSTGRESQL DATABASE BACKUP')
    terminal.box("#{title} - Configuration: #{configuration.get_key(:postgres).to_s}")
    
    if configuration.get_key(:postgres).is_a?(Hash) && configuration.get_key(:postgres).keys.length > 1
      puts "More than one database is defined."
    else
      puts "Only one database is defined or configuration is not in expected format."
    end
    

    end

    private

    def db
      @db ||= Database::Postgres.new
    end

    def storage
      @storage ||= Storage::S3.new
    end

    def discord
      @discord ||= Notifications::Discord.new
    end

    def pushover
      @pushover ||= Notifications::Pushover.new
    end

    def mailgun
      @mailgun ||= Notifications::Mailgun.new
    end

    def configuration
      @configuration ||= Util::Configuration.new
    end

    def terminal
      @disclaimer ||= Util::Terminal.new
    end

    def pastel
      @pastel ||= Pastel.new
    end

    def prompt
      @prompt ||= TTY::Prompt.new
    end

    def configuration_to_text
      [
        show_config_for('Database', configuration.get_key(:postgres)),
        show_config_for('S3', configuration.get_key(:s3)),
      ].compact
    end

    def show_config_for(text, value)
      return if value.empty?

      "* #{pastel.yellow.bold(text)}: #{value}"
    end

    def list_backup_files
      @list_backup_files ||= begin
                               source = configuration.get_key(:s3) ? storage : db
                               source.list_files
                             end
    end
    end
