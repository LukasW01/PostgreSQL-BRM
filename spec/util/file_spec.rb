require 'rspec'
require_relative '../../lib/util/file'

RSpec.describe Util::File do
  before(:each) do
    @file = Util::File.new
  end

  describe '.event' do
    it 'returns the a event from the yaml file' do
      expect(@file.event('backup')).to_not be nil
    end
  end

  describe '.path_init' do
    it 'creates the necessary directories' do
      @file.path_init
      expect(Dir.exist?('lib/log')).to be true
      expect(Dir.exist?('lib/backup')).to be true
    end
  end
end
