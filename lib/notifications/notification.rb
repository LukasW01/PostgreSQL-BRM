require_relative '../configuration/env'
require 'cronex'

class Notification
  def initialize
    @database = Env::Env.new.get_key(:postgres)
  end

  # set priority for pushover messages based on event
  def priority(event)
    case event
    when :backup, :restore
      0
    when :error, :s3
      2
    end
  end

  # search for all databases in @database hash and join them with a comma
  def databases
    @database.values.map { |db| db['database'] }.join(', ')
  end

  # cronex gem to parse cron expressions
  # @daily like expressions are not supported
  def cronex
    Cronex::ExpressionDescriptor.new(ENV.fetch('SCHEDULE', '0 0 * * *')).description
  end
end
