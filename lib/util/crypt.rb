require 'rbnacl'
require_relative '../configuration/env'

module Util
  class Crypt
    def initialize
      @env = Env::Env.new.get_key(:crypt)
      @box = RbNaCl::SimpleBox.from_keypair(@env['public_key'].b, @env['private_key'].b)
    end

    def encrypt_file(file_name)
      file = ::File.read(file_name)
      ciphertext = @box.encrypt(file)
      ::File.write(file_name, ciphertext)
    end

    def decrypt_file(file_name)
      file = ::File.read(file_name)
      plaintext = @box.decrypt(file)
      ::File.write(file_name, plaintext)
    end
  end
end
