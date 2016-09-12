require 'mongo'
require 'slack-ruby-client'
require 'dotenv'
require 'json'
Dotenv.load

def pairingroulette

  Slack.configure do |config|
    config.token = ENV['SLACK_API_TOKEN']
  end

  clientyannis = Mongo::Client.new('mongodb://heroku_9lfp2dtb:5ri9s2lgba2om7t6hl2v3uhp01@ds033734.mlab.com:33734/heroku_9lfp2dtb')
  database = clientyannis.database
  users = database.collection('users')
  mangrovers = users.find.distinct(:id)
  hastoredo = true
  while hastoredo do

    hastoredo = false

    shuffler = mangrovers.shuffle
    newbuddies = []
    number_of_mangrovers = mangrovers.count

    if number_of_mangrovers.even?
      (1..(number_of_mangrovers-1)).each do |number|
        if number % 2 != 0
          newbuddies << [shuffler[(number-1)], shuffler[number]]
        end
      end
    else
      (1..(number_of_mangrovers-1)).each do |number|
        if number % 2 != 0
          newbuddies << [shuffler[(number-1)], shuffler[number]]
        end
      end
      newbuddies << [shuffler[(number_of_mangrovers-3)], shuffler[number_of_mangrovers-1]]
    end

    # check if unique

    pairingdb = database.collection('pairing')
    lastweekbuddies = pairingdb.find.first[:thisweek]

    newbuddies.each do |newarray|
      lastweekbuddies.each do |oldarray|
        if ( (newarray.sort[0] == oldarray.sort[0]) && (newarray.sort[1] == oldarray.sort[1]) ) then
          hastoredo = true
        end
      end
    end
    if newbuddies.last[0] == lastweekbuddies.last[0] && !number_of_mangrovers.even? then
      hastoredo = true
    end
  end

  # write new buddies in DB

  pairingdb.find(:thisweek => lastweekbuddies).replace_one(:thisweek => newbuddies)

  # post new buddies to slack

  # get messages
  file = File.read('pairingmessages.json')
  pairingmessages = JSON.parse(file)


  newclient = Slack::Web::Client.new
  p newclient
  newclient.auth_test

  newclient.chat_postMessage(token: nil, channel: "#general", text: pairingmessages["hello"].sample,  as_user: true)
  newclient.chat_postMessage(token: nil, channel: "#general", text: pairingmessages["announcement"].sample,  as_user: true)

  announce = ""

  newbuddies.each do |couple|
    announce += "> :point_right: " + newclient.users_info(user: couple[0]).user.name + " and " + newclient.users_info(user: couple[1]).user.name + "\n"
  end

  newclient.chat_postMessage(token: nil, channel: "#general", text: announce,  as_user: true)
  newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#general", text: pairingmessages["goodbye"].sample,  as_user: true)
end


def reminder

  Slack.configure do |config|
    config.token = ENV['SLACK_API_TOKEN']
  end
    # get buddies
  clientyannis = Mongo::Client.new('mongodb://heroku_9lfp2dtb:5ri9s2lgba2om7t6hl2v3uhp01@ds033734.mlab.com:33734/heroku_9lfp2dtb')
  database = clientyannis.database
  pairingdb = database.collection('pairing')
  buddies = pairingdb.find.first[:thisweek]
  # get mangrovers
  users = database.collection('users')
  # get messages
  file = File.read('pairingmessages.json')
  pairingmessages = JSON.parse(file)

  newclient = Slack::Web::Client.new

  allbuddies = []

  buddies.each do |buddy|
    if allbuddies.include? buddy[0]
      newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: "And you got another budddy as well!",  as_user: true)
    else
      allbuddies << buddy[0]
      newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: "Hi " + newclient.users_info(user: buddy[0]).user.name + "!",  as_user: true)
      newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: pairingmessages["greetings"].sample,  as_user: true)
      newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: "Just to tell you that your buddy this week is " + newclient.users_info(user: buddy[1]).user.name,  as_user: true)
      buddymood = users.find( { id: buddy[1] } ).first["feedback"].last["status"].to_i
      if buddymood < 4
        newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: pairingmessages["feelingbad"].sample,  as_user: true)
      elsif buddymood > 8
        if rand > 0.3
          newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: pairingmessages["feelinggreat"].sample,  as_user: true)
        end
      end
      if rand > 0.4
        newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: pairingmessages["besttimes"].sample,  as_user: true)
      end
      newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: pairingmessages["goodbyepm"].sample,  as_user: true)
    end
  end

  allbuddies = []

  buddies.each do |buddy|
    if allbuddies.include? buddy[1]
      newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: "And you got another budddy as well!",  as_user: true)
    else
      allbuddies << buddy[1]
      newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: "Hi " + newclient.users_info(user: buddy[1]).user.name + "!",  as_user: true)
      newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: pairingmessages["greetings"].sample,  as_user: true)
      newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: "Just to tell you that your buddy this week is " + newclient.users_info(user: buddy[0]).user.name,  as_user: true)
      buddymood = users.find( { id: buddy[1] } ).first["feedback"].last["status"].to_i
      if buddymood < 4
        newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: pairingmessages["feelingbad"].sample,  as_user: true)
      elsif buddymood > 8
        if rand > 0.3
          newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: pairingmessages["feelinggreat"].sample,  as_user: true)
        end
      end
      if rand > 0.4
        newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: pairingmessages["besttimes"].sample,  as_user: true)
      end
      newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: pairingmessages["goodbyepm"].sample,  as_user: true)
    end
  end
end


def surprise

  Slack.configure do |config|
    config.token = ENV['SLACK_API_TOKEN']
  end
    # get buddies
  clientyannis = Mongo::Client.new('mongodb://heroku_9lfp2dtb:5ri9s2lgba2om7t6hl2v3uhp01@ds033734.mlab.com:33734/heroku_9lfp2dtb')
  database = clientyannis.database
  pairingdb = database.collection('pairing')
  buddies = pairingdb.find.first[:thisweek]

    # get messages
  file = File.read('pairingmessages.json')
  pairingmessages = JSON.parse(file)

  newclient = Slack::Web::Client.new

  buddies.each do |buddy|
    if rand < 0.2
      newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: buddy[0], text: "Hi " + newclient.users_info(user: buddy[0]).user.name + "!",  as_user: true)
      newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: buddy[0], text: pairingmessages["randomlove"].sample,  as_user: true)
    end
  end
end
