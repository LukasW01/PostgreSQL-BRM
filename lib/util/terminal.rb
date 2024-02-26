require_relative 'file'
require 'pastel'
require 'tty-spinner'
require 'tty-box'

module Util
  class Terminal
    def initialize
      @file = Util::File.new
      @pastel = Pastel.new
    end

    def spinner(text)
      spinner = TTY::Spinner.new("#{@pastel.blue('[:spinner] ')}#{text}...")
      spinner.auto_spin
      result = yield
      spinner.success(@pastel.green.bold('done.'))

      result
    end

    def box(text)
      puts TTY::Box.frame(width: 50, title: { top_left: @file.app('name'), bottom_right: @file.app('version') }) { text }
    end
  end
end
