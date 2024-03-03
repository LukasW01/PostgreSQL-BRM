require_relative '../util/terminal'
require_relative '../database/postgres'
require_relative '../storage/s3'
require_relative '../notifications/hooks'
require_relative '../configuration/env'
require_relative '../util/file'
require 'rake'
require 'tty-prompt'
require 'tty-spinner'
require 'pastel'
require 'parallel'

namespace :pg_brm do # rubocop:disable Metrics/BlockLength
  desc 'Dump the database to a file'
  task :dump do
    terminal.box('Dump', env_to_text)

    terminal.spinner("#{pastel.red.bold('Error:')} No databases available") { exit } unless options[:postgres].is_a?(Hash)
    Parallel.each(options[:postgres].keys, in_threads: options[:postgres].keys.length) do |index|
      file_path = terminal.spinner("Backing up database #{index}") { db.dump(index) }

      if options[:s3].is_a?(Hash)
        terminal.spinner('Uploading file') { storage.upload(file_path) }
        terminal.spinner('Deleting local file') { File.delete(file_path) } if File.exist?(file_path)
      end
    end

    terminal.spinner('Sending notifications (u.a : Discord, Mailgun, Pushover)') { hooks.pg_success }
  end

  desc 'Restores a database from a dump'
  task :restore do
    terminal.box('Restore', env_to_text)

    terminal.spinner("#{pastel.red.bold('Error:')} No databases available") { exit } unless options[:postgres].is_a?(Hash)
    index = prompt.select('Select a database to restore', database_index) do |menu|
      menu.choice(pastel.red.bold('Cancle').to_s) { exit }
    end

    terminal.spinner("#{pastel.red.bold('Error:')} No dumps available") { exit } unless list_files(index).any?
    file_path = prompt.select('Select a dump to restore', list_files(index)) do |menu|
      menu.choice(pastel.red.bold('Cancle').to_s) { exit }
    end

    terminal.spinner('Downloading file') { storage.download(file_path) } if options[:s3].is_a?(Hash)
    terminal.spinner('Reseting database') { db.reset(index) }
    terminal.spinner('Restoring database') { db.restore(index, file_path) }
    terminal.spinner('Deleting local file') { File.delete(file_path) } if options[:s3].is_a?(Hash) && File.exist?(file_path)
    terminal.spinner('Sending notifications (u.a : Discord, Mailgun, Pushover)') { hooks.pg_restore }
  end

  private

  def db
    @db ||= Database::Postgres.new
  end

  def storage
    @storage ||= Storage::S3.new
  end

  def hooks
    @hooks ||= Notifications::Hooks.new
  end

  def pastel
    @pastel ||= Pastel.new
  end

  def terminal
    @terminal ||= Util::Terminal.new
  end

  def prompt
    @prompt ||= TTY::Prompt.new
  end

  def file
    @file ||= Util::File.new
  end

  def env
    @env ||= Env::Env.new
  end

  def options
    env.options
  end

  def database_index
    options[:postgres].keys.map { |index| { name: index, value: index } }
  end

  def list_files(index)
    options[:s3].is_a?(Hash) ? storage.list_files(index) : db.list_files(index)
  end

  def env_to_text
    [
      list_config('Database', options[:postgres].is_a?(Hash) ? database_index.map { |index| index[:name] }.join(', ') : 'None'),
      list_config('S3 (bucket)', options[:s3].is_a?(Hash) ? options[:s3]['bucket'] : 'None'),
      list_config('Discord (webhook)', options[:discord].is_a?(Hash) ? 'Enabled' : 'Disabled'),
      list_config('Pushover', options[:pushover].is_a?(Hash) ? 'Enabled' : 'Disabled'),
      list_config('Mailgun', options[:mailgun].is_a?(Hash) ? 'Enabled' : 'Disabled')
    ].compact
  end

  def list_config(text, value)
    return if value.nil?

    "* #{pastel.blue.bold(text)}: #{value}"
  end
end
