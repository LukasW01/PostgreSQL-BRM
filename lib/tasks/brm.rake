require_relative '../util/terminal'
require_relative '../database/postgres'
require_relative '../storage/s3'
require_relative '../notifications/discord'
require_relative '../notifications/pushover'
require_relative '../notifications/mailgun'
require 'tty-prompt'
require 'tty-spinner'
require 'pastel'

namespace :pg_brm do # rubocop:disable Metrics/BlockLength
  desc 'Dumps the database'
  task :dump do
    title = pastel.yellow.bold('POSTGRESQL DATABASE BACKUP')
    terminal.box(title)

    file_path = terminal.spinner('Backing up database') { db.dump }

    if configuration.s3?
      terminal.spinner('Uploading file') { storage.upload(file_path) }
      terminal.spinner('Deleting local file') { File.delete(file_path) } if File.exist?(file_path)
    end

    puts pastel.green('\nAll done.')
  end

  desc 'Test'
  task :test do
    title = pastel.yellow.bold('POSTGRESQL DATABASE BACKUP')
    terminal.box(title)

    terminal.spinner('Testing') { puts 'Testing' }
    terminal.spinner('Sending discord notification') { discord.send(:backup) }
  end

  desc 'Restores a database backup into the database'
  task :restore do
    title = pastel.green('POSTGRESQL DATABASE RESTORE')
    terminal.box(title)

    local_file_path = ''
    files = terminal.spinner('Loading backups list') { list_backup_files }

    if files.present?
      puts ''
      file_name = prompt.select('Choose the file to restore', files)
      puts ''

      local_file_path = terminal.spinner('Downloading file') { storage.download(file_name) } if configuration.s3?

      db.reset

      terminal.spinner('Restoring data') { db.restore(file_name) }

      terminal.spinner('Deleting local file') { File.delete(local_file_path) } if configuration.s3?

      puts ''
      puts pastel.green('All done.')
    else
      spinner = TTY::Spinner.new("#{pastel.yellow('[:spinner] ')}Restoring data...")
      error_message = "#{pastel.red.bold('failed')}. Backup files not found."
      spinner.success(error_message)
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
    @pushover ||= Notifications::PushOver.new
  end

  def mailgun
    @mailgun ||= Notifications::MailGun.new
  end

  def pastel
    @pastel ||= Pastel.new
  end

  def terminal
    @terminal ||= Util::Terminal.new
  end

  def configuration_to_text
    [
      show_config_for('Database', configuration.get_key(:postgres)),
      show_config_for('S3', configuration.get_key(:s3))
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
