require 'rspec'
require_relative '../../lib/configuration/env'

RSpec.describe Env::Validation do
  let(:validation) { Env::Validation.new }
  let(:env) { instance_double('Env::Env') }

  before do
    allow(Env::Env).to receive(:new).and_return(env)
    @options = {
      postgres: {
        db: {
          host: 'localhost', port: 5432, database: 'postgres', user: 'root', password: ''
        }
      }
    }
  end

  it 'validates postgres key successfully' do
    allow(env).to receive(:options).and_return(@options)
    expect { validation.validate(:postgres) }.not_to raise_error
  end

  it 'raises error for empty postgres options' do
    empty_options = {}
    allow(env).to receive(:options).and_return(empty_options)
    expect { validation.validate(:postgres) }.to raise_error(RuntimeError)
  end
end
