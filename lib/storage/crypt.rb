require 'rbnacl'
require_relative '../configuration/env'
require 'logger'

module Storage
  class Crypt
    def initialize
      @env = Env::Env.new.get_key(:crypt)
      @box = RbNaCl::SimpleBox.from_keypair(@env['public_key'].b, @env['private_key'].b)
      @logger = Logger.new('lib/log/ruby.log')
    end

    def encrypt_file(file_name)
      File.open(file_name, 'r') do |file|
        File.write("#{file_name}.enc", @box.encrypt(file.read))
      end
    rescue StandardError => e
      @logger.error("Error encrypting file #{file_name} \nERROR: #{e.message}")
    end

    def decrypt_file(file_name)
      File.open(file_name, 'r') do |file|
        File.write("#{file_name}.dec", @box.decrypt(file.read))
      end
    rescue StandardError => e
      @logger.error("Error decrypting file #{file_name} \nERROR: #{e.message}")
    end
  end
end
