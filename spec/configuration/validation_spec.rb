require 'rspec'
require_relative '../../lib/configuration/env'

RSpec.describe Env::Validation do
  let(:validation) { Env::Validation.new }
  let(:env) { instance_double('Env::Env') }

  before do
    allow(Env::Env).to receive(:new).and_return(env)
  end

  let(:options) { { postgres: { db: { host: 'localhost', port: 5432, database: 'postgres', user: 'root', password: '' } } } }

  describe '.validate' do
    it 'validates postgres key successfully' do
      allow(env).to receive(:options).and_return(options)
      expect { validation.validate(:postgres) }.not_to raise_error
    end
  end

  describe '.validate' do
    it 'raises error for empty postgres options' do
      allow(env).to receive(:options).and_return({})
      expect { validation.validate(:postgres) }.to raise_error(RuntimeError)
    end
  end
end
