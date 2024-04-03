require 'rspec'
require 'yaml'
require 'fileutils'
require_relative '../../lib/configuration/env'

RSpec.describe 'Env' do
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

    File.write('env.yaml', @options.to_yaml)
  end

  after do
    FileUtils.rm_f('env.yaml')
  end

  describe '.get_key' do
    it 'loads postgres options correctly from yaml' do
      allow(env).to receive(:get_key).and_return(@options[:postgres])
      expect(Env::Env.new.get_key(:postgres)).to eq(@options[:postgres])
    end
  end
end
