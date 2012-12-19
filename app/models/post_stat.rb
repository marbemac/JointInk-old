# == Schema Information
#
# Table name: post_stats
#
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  ip_address   :string(255)
#  post_id      :integer
#  referral_url :string(255)
#  stat_type    :string(255)
#  updated_at   :datetime         not null
#  user_id      :integer
#  value        :string(255)
#

class PostStat < ActiveRecord::Base

  belongs_to :post
  belongs_to :user

  def self.retrieve(post_id, stat_type, ip_address, user_id)
    stat = PostStat.where(:post_id => post_id, :stat_type => stat_type)
    if user_id
      stat = stat.where(:user_id => user_id)
    else
      stat = stat.where(:ip_address => ip_address)
    end
    stat.first
  end

  def self.add(post_id, ip_address, stat_type, referral_url, user_id=nil, value=nil)
    stat = retrieve(post_id, stat_type, ip_address, user_id)
    return false if stat
    stat = PostStat.new
    stat.post_id = post_id
    stat.ip_address = ip_address
    stat.referral_url = referral_url
    stat.stat_type = stat_type
    stat.user_id = user_id
    stat.value = value
    stat.save
  end

end