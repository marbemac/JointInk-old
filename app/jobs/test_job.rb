class TestJob
  include #resque::Plugins::UniqueJob
  @queue = :fast

  def self.perform(post_id)
    post = Post.find(post_id)
    return unless post

    category_found = false

    topic_ids = []
    post.shares.each do |s|
      s.topic_mention_ids.each do |tid|
        topic_ids << tid
      end
    end

    category = Channel.where(:_id => {"$in" => topic_ids}, :is_category => true).first
    if category
      category_found = true
      post.shares.each do |s|
        s.category_id = category.id
        s.crowdsourced = true
      end
    end

    if post._type != 'Picture' && !category_found
      category = Channel.category_suggestion(post.primary_source.url)
      if category
        category_found = true
        post.shares.each do |s|
          s.category_id = category.id
          s.crowdsourced = true
        end
      end
    end


    if category_found
      post.status = 'active' unless post.status == 'active'
      post.shares.each do |s|
        if s.is_public?
          s.status = 'active'
        end
      end
    elsif !post.rturk_hits['add_category']
      post.create_turker_category_hit
    end

    post.save
  end
end