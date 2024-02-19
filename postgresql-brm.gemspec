Gem::Specification.new do |s|
  s.name        = 'postgresql-brm'
  s.version     = '0.0.5'
  s.summary     = "Automate PostgreSQL's backup and restore process inside a Docker container."
  s.authors     = ["Lukas W."]
  s.email       = 'lukas@wigger.dev'
  s.homepage    = 'https://gitlab.com/LukasW01/PostgreSQL-BRM'
  s.files       = `git ls-files -- lib/*`.split("\n")
  s.files       += %w[README.md CHANGELOG.md, LICENSE]
  s.license     = 'MIT'

  # Development dependencies
  s.add_development_dependency 'bump', '~> 0.10.0'
  s.add_development_dependency 'rails', '~> 6.1'
  s.add_development_dependency 'rake', '~> 13.1'
  s.add_development_dependency 'rspec', '~> 3.13.0'
  s.add_development_dependency 'rubocop', '~> 1.60.2'
  s.add_development_dependency 'simplecov', '~> 0.22.0'

  # Dependencies:
  s.add_dependency 'fog-aws', '>= 3.13', '< 3.22'
  s.add_dependency 'pastel', '~> 0.8.0'
  s.add_dependency 'tty-prompt', '~> 0.23.0'
  s.add_dependency 'tty-spinner', '~> 0.9.3'
  s.add_dependency 'pushover', '~> 3.0'
  s.add_dependency 'discordrb', '~> 3'
  s.add_dependency 'mailgun-ruby', '~>1.2.14'
end
