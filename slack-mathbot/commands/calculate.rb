require 'json'

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

        couple1 = ":small_blue_diamond: " + buddies[0] + " and " + buddies[1]
        couple2 = ":small_blue_diamond: " + buddies[2] + " and " + buddies[3]
        couple3 = ":small_blue_diamond: " + buddies[2] + " and " + buddies[4]
        client.say(channel: data.channel, text: "We are the pairing dancers!")
        client.say(channel: data.channel, text: "This week\'s buddies:")
        client.say(channel: data.channel, text: couple1)
        client.say(channel: data.channel, text: couple2)
        client.say(channel: data.channel, text: couple3)
        client.say(channel: data.channel, text: "Remember: 5 to 10 min a day")
        client.say(channel: data.channel, text: ":dancers: *Let\'s dance!* :dancers:")
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
