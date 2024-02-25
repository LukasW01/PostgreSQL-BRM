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
    terminal.box('wip')
  end

  desc 'Test'
  task :test do
    title = pastel.yellow.bold('Test')
    terminal.box(title)
  end

  desc 'Restores a database backup into the database'
  task :restore do
    terminal.box('wip')
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

  def configuration
    @configuration ||= Env.new
  end

  def configuration_to_text
    [
      show_config_for('S3', configuration.get_key(:s3).is_a?(Hash) ? 'True' : 'False'),
      show_config_for('Database', configuration.get_key(:database).is_a?(Hash) ? 'True' : 'False')
    ].compact
  end

  def show_config_for(text, value)
    return if value.empty?

    "* #{pastel.yellow.bold(text)}: #{value}"
  end
end
