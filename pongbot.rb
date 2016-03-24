require 'slack-ruby-bot'

class PongBot < SlackRubyBot::Bot
  command 'are you ready?' do |client, data, match|
    client.say(text: 'can\'t wait to dance!', channel: data.channel)
  end
end

PongBot.run
