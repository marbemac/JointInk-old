namespace :soulmate do
  include Rails.application.routes.url_helpers

  desc "Rebuild master users, following users, and master topics soulmate data."
  task :all => [:rebuild_users, :rebuild_users_following, :rebuild_topics]

  desc "Rebuild the master users soulmate."
  task :rebuild_users => :environment do
    include Rails.application.routes.url_helpers
    include SoulmateHelper

    users = User.where(:status => 'active')

    soulmate_data = Array.new
    users.each do |user|
      soulmate_data << user_nugget(user)
    end
    Soulmate::Loader.new("user").load(soulmate_data)

    print "Loading #{soulmate_data.length} users into soulmate.\n"
  end

  desc "Rebuild each users following soulmate database."
  task :rebuild_users_following => :environment do
    include SoulmateHelper

    users = User.where(:status => 'active')

    user_processed = 0
    following_processed = 0
    users.each do |user|
      user_processed += 1
      if user.following_users_count > 0
        soulmate_data = Array.new
        following = User.where(:_id.in => user.following_users)
        following.each do |following_user|
          following_processed += 1
          soulmate_data << user_nugget(following_user)
        end
        Soulmate::Loader.new("#{user.id}").load(soulmate_data)
      end
    end

    print "Loading #{following_processed} followed users spread across #{user_processed} users into soulmate.\n"
  end

  desc "Rebuild the master topic soulmate database."
  task :rebuild_topics => :environment do
    include SoulmateHelper

    topics = Channel.where(:status => 'active')

    topic_count = 0
    soulmate_data = Array.new
    topics.each do |topic|
      topic_count += 1
      soulmate_data << topic_nugget(topic)
    end

    Soulmate::Loader.new("topic").load(soulmate_data)

    print "Loading #{topic_count} topics into soulmate.\n"
  end
end