require 'pastel'
require 'tty-spinner'
require 'tty-box'
require 'tty-table'
require 'tty-config'


module Util
  class Terminal
    def spinner(text)
      pastel = Pastel.new
      spinner = TTY::Spinner.new("#{pastel.yellow('[:spinner] ')}#{text}...")
      spinner.auto_spin
      result = yield
      spinner.success(pastel.green.bold('done.'))

      result
    end
    
    def box(text)
      puts TTY::Box.frame(width: 50, title: {top_left: "pg_brm", bottom_right: "v0.5"}) { text }
    end
  end
end
