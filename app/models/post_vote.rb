# == Schema Information
#
# Table name: post_votes
#
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  ip_address   :string(255)
#  post_id      :integer
#  referral_url :string(255)
#  updated_at   :datetime         not null
#  user_id      :integer
#  value        :string(255)
#

class PostVote < ActiveRecord::Base

  belongs_to :post
  belongs_to :user

  after_create :increase_post_votes
  before_destroy :decrease_post_votes

  def increase_post_votes
    post.votes_count += 1
    post.save
  end

  def decrease_post_votes
    post.votes_count -= 1
    post.save
  end

  def self.retrieve(post_id, ip_address, user_id)
    vote = PostVote.where(:post_id => post_id)
    if user_id
      vote = vote.where(:user_id => user_id)
    else
      vote = vote.where("ip_address = ? AND user_id IS NULL", ip_address)
    end
    vote.first
  end

  def self.add(post_id, ip_address, user_id=nil, value=nil)
    vote = retrieve(post_id, ip_address, user_id)
    return false if vote

    vote = PostVote.new
    vote.post_id = post_id
    vote.ip_address = ip_address
    vote.user_id = user_id
    vote.value = value
    vote.save
  end

end
