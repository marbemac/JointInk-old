desc "This task is called by the Heroku scheduler add-on"

task :generate_page_view_stats => :environment do
  user = User.find(1)
  30.times do |i|
    low = i*1
    high = i*5

    amount = rand(low..high)
    amount.times do |i2|
      post = user.posts.order("RANDOM()").first

      referer = ['http://google.com','http://bing.com','http://yahoo.com','http://facebook.com',nil,'http://jointink.com','http://twitter.com']

      if rand(3) % 2 == 1 && post.primary_channel
        referer = "http://jointink.com/#{post.primary_channel.to_param}"
      else
        referer = referer[rand(7)]
      end

      stat = Stat.create_from_page_analytics('Page View', nil, [post], referer, nil)
      stat.created_at = (30-(i+1)).days.ago
      stat.save
    end
  end
end

task :generate_recommend_stats => :environment do
  user = User.find(1)
  30.times do |i|
    low = i*1
    high = i*2

    amount = [(rand(low..high)/5).to_i, 0].max
    amount.times do |i2|
      post = user.posts.order("RANDOM()").first

      referer = ['http://google.com','http://bing.com','http://yahoo.com','http://facebook.com',nil,'http://jointink.com','http://twitter.com']

      if rand(3) % 2 == 1 && post.primary_channel
        referer = "http://jointink.com/#{post.primary_channel.to_param}"
      else
        referer = referer[rand(7)]
      end

      stat = Stat.create_from_page_analytics('Recommend', nil, [post], referer, nil)
      stat.created_at = (30-(i+1)).days.ago
      stat.save
    end
  end
end

task :generate_read_stats => :environment do
  user = User.find(1)
  30.times do |i|
    low = i*1
    high = i*3

    amount = [(rand(low..high)/2).to_i, 0].max
    amount.times do |i2|
      post = user.posts.order("RANDOM()").first

      referer = ['http://google.com','http://bing.com','http://yahoo.com','http://facebook.com',nil,'http://jointink.com','http://twitter.com']

      if rand(3) % 2 == 1 && post.primary_channel
        referer = "http://jointink.com/#{post.primary_channel.to_param}"
      else
        referer = referer[rand(7)]
      end

      stat = Stat.create_from_page_analytics('Read', nil, [post], referer, nil)
      stat.created_at = (30-(i+1)).days.ago
      stat.save
    end
  end
end