require 'rspec'
require_relative '../../lib/util/terminal'

RSpec.describe Util::Terminal do
  let(:terminal) { Util::Terminal.new }

  describe '.spinner' do
    it 'starts the spin' do
      expect_any_instance_of(TTY::Spinner).to receive(:auto_spin).and_call_original
      terminal.spinner('testing the spinner') { true }
    end

    it 'returns the block value' do
      result = terminal.spinner('testing the spinner') { 10 }
      expect(result).to eq(10)
    end
  end

  describe '.box' do
    it 'outputs the correct string' do
      text = 'Hello, world!'
      bullets = ['Bullet 1', 'Bullet 2']
      expected_output = TTY::Box.frame(width: 50, title: { top_left: 'pg_brm', bottom_right: 'v1.3' }) do
        "#{text}\n\n#{bullets.join("\n")}"
      end

      expect { terminal.box(text, bullets) }.to output(expected_output).to_stdout
    end
  end
end
