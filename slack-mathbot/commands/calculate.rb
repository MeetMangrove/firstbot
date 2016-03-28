require 'json'
require 'picky'

module SlackMathbot
  module Commands
    class Calculate < SlackRubyBot::Commands::Base

      command 'buddies' do |client, data, _match|
        mangrovers = ["adrien", "max", "olivier", "yannis", "matthieu"]

        db = File.read('buddies.json')
        oldbuddies = JSON.parse(db)
        notrandom = true

        while notrandom
          buddies = mangrovers.shuffle
          newbuddies = {
            "couple1" => [buddies[0], buddies[1]],
            "couple2" => [buddies[2], buddies[3]],
            "couple3" => [buddies[2], buddies[4]]
          }
          notrandom = false
          notunique = false
          newbuddies.each do |key, value|
            oldbuddies.each do |oldkey, oldvalue|
              if (newbuddies[key].sort == oldbuddies[oldkey].sort) || (newbuddies["couple2"][0] == oldbuddies["couple2"][0])
                notunique = true
              end
            end
          end
          notrandom = true if notunique
        end


        File.open("buddies.json","w") do |f|
          f.write(newbuddies.to_json)
        end

        couple1 = ":point_right: " + buddies[0] + " and " + buddies[1]
        couple2 = ":point_right: " + buddies[2] + " and " + buddies[3]
        couple3 = ":point_right: " + buddies[2] + " and " + buddies[4]
        client.say(channel: data.channel, text: "We are the pairing dancers!")
        client.say(channel: data.channel, text: "This week\'s buddies:")
        client.say(channel: data.channel, text: couple1)
        client.say(channel: data.channel, text: couple2)
        client.say(channel: data.channel, text: couple3)
        client.say(channel: data.channel, text: "Remember: 5 to 10 min a day")
        client.say(channel: data.channel, text: "*Let\'s dance!* :dancers:")
      end

      command 'reminder' do |client, data, _match|
        db = File.read('buddies.json')
        buddies = JSON.parse(db)
        client.say(channel: '#general', text: "Just testing some dance moves!")
        client.say(channel: data.channel, text: "hey hey")

        newclient = Slack::Web::Client.new
        max = newclient.users_info(user: '@max')
        newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: max.user.id, text: "it worked!",  as_user: true)
      end
    end
  end
end


# LUNDI
# récupérer la liste des membres du channel
# générer une nouvelle combinaison originale

# MARDI AU VENDREDI
# rappeler à 18h d'appeler son buddy

# PUSH CA AUX BON MOMENTS
# soit bootstrap avec IFTTT
# soit webhook
