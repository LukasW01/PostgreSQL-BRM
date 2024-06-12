# spec/crypt_spec.rb

require 'rspec'
require 'rbnacl'
require 'fileutils'
require_relative '../../lib/util/crypt'
require_relative '../../lib/configuration/env'

RSpec.describe Util::Crypt do
  let(:public_key) { RbNaCl::PrivateKey.generate.public_key }
  let(:private_key) { RbNaCl::PrivateKey.generate }
  let(:env) { { 'public_key' => 'f4a2696c41ee07164feaa3ba6a640c75', 'private_key' => '2cb66adbb82072205b405564d5e46498' } }

  before do
    allow(Env::Env).to receive(:new).and_return(double(get_key: env))
  end

  let(:crypt) { Util::Crypt.new }
  let(:file_name) { 'test_file.txt' }
  let(:content) { 'Hello, world!' }

  before do
    File.write(file_name, content)
  end

  after do
    FileUtils.rm_f(file_name)
  end

  describe '#encrypt_file' do
    it 'encrypts the file content' do
      crypt.encrypt_file(file_name)
      encrypted_content = File.read(file_name)
      expect(encrypted_content).not_to eq(content)
    end
  end

  describe '#decrypt_file' do
    it 'decrypts the file content back to original' do
      crypt.encrypt_file(file_name)
      crypt.decrypt_file(file_name)
      decrypted_content = File.read(file_name)
      expect(decrypted_content).to eq(content)
    end
  end
end
