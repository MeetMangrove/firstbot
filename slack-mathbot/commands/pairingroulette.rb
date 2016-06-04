require 'mongo'


  clientyannis = Mongo::Client.new('mongodb://heroku_9lfp2dtb:5ri9s2lgba2om7t6hl2v3uhp01@ds033734.mlab.com:33734/heroku_9lfp2dtb')
  database = clientyannis.database
  users = database.collection('users')
  mangrovers = users.find.distinct(:id)
  # mangrovers = ["adrien", "max", "olivier", "yannis", "matthieu"]
  p mangrovers

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

  newclient = Slack::Web::Client.new

  newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: "We are the pairing dancers!",  as_user: true)
  newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: "And this week\'s buddies are...",  as_user: true)

  announce = ""

  newbuddies.each do |couple|
    announce += ":point_right: " + couple[0] + " and " + couple[1] + "\n"
  end


  newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: announce,  as_user: true)
  newclient.chat_postMessage(token: ENV["SLACK_API_TOKEN"], channel: "#botspam", text: "These guys have strange names ahaha",  as_user: true)

