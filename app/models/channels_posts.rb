# == Schema Information
#
# Table name: channels_posts
#
#  channel_id :integer
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  post_id    :integer
#  updated_at :datetime         not null
#  user_id    :integer
#

class ChannelsPosts < ActiveRecord::Base
  belongs_to :user
  belongs_to :channel
  belongs_to :post
end
