require 'discordrb'

module Tools
  class Discord
    def initialize(configuration)
      @configuration = configuration
      @discord = Discordrb::Webhooks::Client.new(url: configuration.url)
    end

    # Send a message to the Discord channel.
    #
    # ```
    # @discord.execute do |builder|
    #  builder.content = 'Hello world!'
    #  builder.add_embed do |embed|
    #   embed.title = 'Embed title'
    #   embed.description = 'Embed description'
    #   embed.timestamp = Time.now
    #  end
    # ```
    def send(message)
      @discord.execute do |builder|
        builder.content = 'Hello world!'
        builder.add_embed do |embed|
          embed.title = 'Embed title'
          embed.description = 'Embed description'
          embed.timestamp = Time.now
        end
      end
    end
    
    private

    attr_reader :configuration, :discord
    
    def url
      @url ||= @configuration.url
    end
    
    
  end
end