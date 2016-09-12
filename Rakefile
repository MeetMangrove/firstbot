require './pairingsecond.rb'
task :default => [:test]

task :test do
  pairingroulette
end

task :roulette do
  if Time.now.monday?
    pairingroulette
  end
end

task :reminder do
  # if Time.now.tuesday?
    reminder
  # end
end

task :surprise do
  if Time.now.friday?
    surprise
  end
end
