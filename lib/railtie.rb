require 'postgresql_backup'
require 'rails'

module PostgresqlBackup
  class Railtie < Rails::Railtie
    railtie_name 'brm'

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/*.rake").each { |f| load f }
    end
  end
end
