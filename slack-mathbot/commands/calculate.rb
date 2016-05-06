require 'json'
require 'picky'

module SlackMathbot
  module Commands
    class Calculate < SlackRubyBot::Commands::Base

      command 'buddies' do |client, data, _match|

        # get mangrovers and previous buddies
        mangroversdb = File.read('mangrovers.json')
        mangrovers = JSON.parse(mangroversdb)["mangrovers"]

        buddiesdb = File.read('buddies.json')
        oldbuddies = JSON.parse(buddiesdb)
        notrandom = true

        # tirage au sort
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

        # TESTS BEFORE updating DB

        p "============ OLD BUDDIES ============"
        p oldbuddies
        p "============= NEW BUDDIES ==========="
        p newbuddies

        # update DB
        File.open("buddies.json","w") do |f|
          f.write(newbuddies.to_json)
        end

        p "============= NEW BUDDIES IN JSON FILE ==========="
        newbuddiesjsondb = File.read('buddies.json')
        newbuddiesjson = JSON.parse(newbuddiesjsondb)
        p newbuddiesjson

        # give new buddies on #general
        # newclient = Slack::Web::Client.new

        couple1 = ":point_right: " + buddies[0] + " and " + buddies[1]
        couple2 = ":point_right: " + buddies[2] + " and " + buddies[3]
        couple3 = ":point_right: " + buddies[2] + " and " + buddies[4]

        # newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: "We are the pairing dancers!",  as_user: true)
        # newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: "And this week\'s buddies are...",  as_user: true)
        # newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: couple1,  as_user: true)
        # newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: couple2,  as_user: true)
        # newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: couple3,  as_user: true)
        # newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: "Remember: 5 to 10 min a day",  as_user: true)
        # newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: "*Let\'s dance!* :dancers:",  as_user: true)
      end

      command 'reminder' do |client, data, _match|
        # get buddies
        buddiesdb = File.read('buddies.json')
        buddies = JSON.parse(buddiesdb)

        client.say(channel: '#botspam', text: "Reminder ready")

        newclient = Slack::Web::Client.new

        buddies.each do |couple, arrayofbud|
          bud1 = arrayofbud[0]
          bud2 = arrayofbud[1]
          bud1info = newclient.users_info(user: '@' + bud1)
          newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: bud1info.user.id, text: "Wooow! Don\'t forget to call " + bud2 + " today. Keep on dancing! :dancers:",  as_user: true)
          bud2info = newclient.users_info(user: '@' + bud2)
          newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: bud2info.user.id, text: "Wooow! Don\'t forget to call " + bud1 + " today. Keep on dancing! :dancers:",  as_user: true)
        end

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
