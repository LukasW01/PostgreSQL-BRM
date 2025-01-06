require 'rspec'
require_relative '../../lib/notification/notification'
require_relative '../../lib/configuration/env'

RSpec.describe 'Notification' do
  let(:env) { instance_double('Env::Env') }
  let(:notification) { Notification.new }

  before do
    allow(Env::Env).to receive(:new).and_return(env)
    allow(env).to receive(:get_key).with(:postgres).and_return({ db1: { 'database' => 'db1' }, db2: { 'database' => 'db2' } })
  end

  describe '#initialize' do
    it 'sets @database with postgres options' do
      expect(notification.instance_variable_get(:@database)).to eq({ db1: { 'database' => 'db1' }, db2: { 'database' => 'db2' } })
    end
  end

  describe '#priority' do
    it 'returns 0 for backup and restore events' do
      expect(notification.priority(:backup)).to eq(0)
      expect(notification.priority(:restore)).to eq(0)
    end

    it 'returns 2 for error and s3 events' do
      expect(notification.priority(:error)).to eq(2)
      expect(notification.priority(:s3)).to eq(2)
    end
  end

  describe '#databases' do
    it 'returns a comma-separated string of database names' do
      expect(notification.databases).to eq('db1, db2')
    end
  end

  describe '#cronex' do
    it 'returns the description of the cron expression' do
      allow(ENV).to receive(:fetch).with('SCHEDULE', '0 0 * * *').and_return('0 0 * * *')
      expect(notification.cronex).to eq('At 12:00 AM')
    end
  end
end
