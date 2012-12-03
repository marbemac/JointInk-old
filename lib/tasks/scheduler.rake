desc "This task is called by the Heroku scheduler add-on"
task :fetch_feeds => :environment do
  User.all.each do |user|
    puts "User ##{user.id} - #{user.name}"
    user.accounts.each do |account|
      puts "Account ##{account.id}"
      account.fetch_feed
    end
    puts "done."
  end
end