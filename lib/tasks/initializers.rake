desc "Confirm all existing users"
task :confirm_all => :environment do
  # get users who have not been confirmed
  users = User.where(:conrimed_at => { "$exists" => false })

  users.each do |user|
    user.confirmed_at = user.created_at
    user.save
  end
end

task :channel_response_counts => :environment do
  Post.update_all(:response_count => 0, :talking_ids => [])
  Channel.update_all(:response_count => 0, :talking_ids => [])

  Post.where(:response_to => { "$exists" => false }).each do |obj|
    obj.update_response_counts
    if obj._type == "Talk"
      obj.comments.each do |comment|
        #TODO: get this to set user_snippet.id's which are wrong
        comment.user_id = comment.user_id if comment.user_id
        comment.save
        comment.add_to_count
      end
    end
  end
end