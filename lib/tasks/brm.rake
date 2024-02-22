require_relative '../util/disclaimer'
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
    title = pastel.yellow.bold('POSTGRESQL BACKUP')
    text = 'You are about to backup your database. Relax on your seat, this process is usually fast and you don\'t need to do anything except wait for the process to end. Here is the current configuration for this backup:'
    texts = [text, ' ', configuration_to_text].flatten
    disclaimer.show(title: title, texts: texts)

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
    text = 'Let\'s get your data back. You will be prompted to choose the file to restore, but that\'s all, you can leave the rest to us. Here is the current configuration for this restore:'
    texts = [text, ' ', configuration_to_text].flatten
    disclaimer.show(title: title, texts: texts)
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

  private

  def configuration
    @configuration ||= begin
      config = PostgresqlBackup.configuration.dup
      config.repository = ENV['BKP_REPOSITORY'] if ENV['BKP_REPOSITORY'].present?
      config.bucket = ENV['BKP_BUCKET'] if ENV['BKP_BUCKET'].present?
      config.region = ENV['BKP_REGION'] if ENV['BKP_REGION'].present?
      config.remote_path = ENV['BKP_REMOTE_PATH'] if ENV['BKP_REMOTE_PATH'].present?
      config
    end
  end

  def db
    @db ||= Database::Database.new
  end

  def storage
    @storage ||= Storage::S3.new
  end

  def disclaimer
    @disclaimer ||= Util::Disclaimer.new
  end

  def pastel
    @pastel ||= Pastel.new
  end

  def prompt
    @prompt ||= TTY::Prompt.new
  end

  def configuration_to_text
    [
      show_config_for('Repository', configuration.repository),
      configuration.s3? ? nil : show_config_for('Folder', configuration.backup_folder),
      show_config_for('File suffix', configuration.file_suffix),
      configuration.s3? ? show_config_for('Bucket', configuration.bucket) : nil,
      configuration.s3? ? show_config_for('Region', configuration.region) : nil,
      configuration.s3? ? show_config_for('Remote path', configuration.remote_path) : nil
    ].compact
  end

  def show_config_for(text, value)
    return if value.empty?

    "* #{pastel.yellow.bold(text)}: #{value}"
  end

  def list_backup_files
    @list_backup_files ||= begin
      source = configuration.s3? ? storage : db
      source.list_files
    end
  end
end
