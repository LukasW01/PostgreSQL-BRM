require_relative '../util/terminal'
require_relative '../database/postgres'
require_relative '../storage/s3'
require_relative '../notifications/discord'
require_relative '../notifications/pushover'
require_relative '../notifications/mailgun'
require_relative '../util/file'
require_relative '../configuration/env'
require 'tty-prompt'
require 'tty-spinner'
require 'pastel'

namespace :pg_brm do # rubocop:disable Metrics/BlockLength
  desc 'Dumps the database'
  task :dump do
    terminal.box('Dump')
  end

  desc 'Restores a database backup into the database'
  task :restore do
    terminal.box('Restore')
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

  def file
    @file ||= Util::File.new
  end

  def env
    @env ||= Env::Env.new
  end

  def env_to_text
    [
      list_config('S3', env.get_key(:s3).is_a?(Hash) ? 'True' : 'False'),
      list_config('Database', env.get_key(:database).is_a?(Hash) ? 'True' : 'False')
    ].compact
  end

  def list_config(text, value)
    return if value.empty?

    "* #{pastel.yellow.bold(text)}: #{value}"
  end
end
