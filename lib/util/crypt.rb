require 'rbnacl'
require_relative '../configuration/env'
require 'logger'

module Util
  class Crypt
    def initialize
      @env = Env::Env.new.get_key(:crypt)
      @box = RbNaCl::SimpleBox.from_keypair(@env['public_key'].b, @env['private_key'].b)
      @logger = Logger.new('lib/log/ruby.log')
    end

    def encrypt_file(file_name)
      file = ::File.read(file_name)
      ciphertext = @box.encrypt(file)
      ::File.write(file_name, ciphertext)
    rescue StandardError => e
      @logger.error("Error encrypting file #{file_name} \nERROR: #{e.message}")
      exit!
    end

    def decrypt_file(file_name)
      file = ::File.read(file_name)
      plaintext = @box.decrypt(file)
      ::File.write(file_name, plaintext)
    rescue StandardError => e
      @logger.error("Error decrypting file #{file_name} \nERROR: #{e.message}")
      exit!
    end
  end
end
