require_relative '../util/terminal'
require_relative '../database/postgres'
require_relative '../storage/s3'
require_relative '../notifications/hooks'
require_relative '../configuration/env'
require_relative '../util/file'
require 'tty-prompt'
require 'tty-spinner'
require 'pastel'

namespace :pg_brm do # rubocop:disable Metrics/BlockLength
  desc 'Dumps the database'
  task :dump do
    terminal.box('Dump')
    puts env_to_text

    env.get_key(:postgres).each_key do |(index)|
      file_path = terminal.spinner("Backing up database #{index}") { db.dump(index) }

      if env.get_key(:s3).is_a?(Hash)
        terminal.spinner('Uploading file') { storage.upload(file_path) }
        terminal.spinner('Deleting local file') { File.delete(file_path) } if File.exist?(file_path)
      end
    end

    terminal.spinner('Sending notifications (u.a : Discord, Mailgun, Pushover)') { hooks.pg_success }
  end

  desc 'Restores a database from a dump'
  task :restore do
    terminal.box('Restore')
    puts env_to_text

    index = prompt.select('Select a database to restore', database_index) do |menu|
      menu.choice('Cancel') { exit }
    end

    if list_files(index).any?
      file_path = prompt.select('Select a dump to restore', list_files(index)) do |menu|
        menu.choice('Cancel') { exit }
      end

      terminal.spinner('Downloading file') { storage.download(file_path) } if env.get_key(:s3).is_a?(Hash)
      terminal.spinner('Reseting database') { db.reset(index) }
      terminal.spinner('Restoring database') { db.restore(index, file_path) }
      terminal.spinner('Deleting local file') { File.delete(file_path) } if env.get_key(:s3).is_a?(Hash) && File.exist?(file_path)
      terminal.spinner('Sending notifications (u.a : Discord, Mailgun, Pushover)') { hooks.pg_restore }
    else
      terminal.spinner("#{pastel.red.bold('Error:')} No dumps available") { exit }
    end
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

  def database_index
    env.get_key(:postgres).keys.map { |index| { name: index, value: index } }
  end

  def env_to_text
    [
      list_config('Database', database_index.map { |index| index[:name] }.join(', ')),
      list_config('S3 (bucket)', env.get_key(:s3).is_a?(Hash) ? env.get_key(:s3)['bucket'] : nil),
      list_config('Discord (webhook)', env.get_key(:discord).is_a?(Hash) ? 'Enabled' : 'Disabled'),
      list_config('Pushover', env.get_key(:pushover).is_a?(Hash) ? 'Enabled' : 'Disabled'),
      list_config('Mailgun', env.get_key(:mailgun).is_a?(Hash) ? 'Enabled' : 'Disabled')
    ].compact
  end

  def list_config(text, value)
    return if value.nil?

    "* #{pastel.blue.bold(text)}: #{value}"
  end

  def list_files(index)
    env.get_key(:s3).is_a?(Hash) ? storage.list_files(index) : db.list_files(index)
  end
end
