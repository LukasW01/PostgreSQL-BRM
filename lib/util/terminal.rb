require 'pastel'
require 'tty-spinner'
require 'tty-box'

module Util
  class Terminal
    def initialize
      @pastel = Pastel.new
    end

    def spinner(text)
      spinner = TTY::Spinner.new("#{@pastel.blue('[:spinner] ')}#{text}...")
      spinner.auto_spin
      result = yield
      spinner.success(@pastel.green.bold('done.'))

      result
    end

    def box(text, bullets)
      puts TTY::Box.frame(width: 50, title: { top_left: 'pg_brm', bottom_right: 'v1.3' }) {
        "#{text}\n\n#{bullets.join("\n")}"
      }
    end
  end
end
