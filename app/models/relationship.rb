# == Schema Information
#
# Table name: relationships
#
#  created_at  :datetime         not null
#  followed_id :integer
#  follower_id :integer
#  id          :integer          not null, primary key
#  updated_at  :datetime         not null
#

class Relationship < ActiveRecord::Base
  attr_accessible :followed_id

  belongs_to :follower, :class_name => "User"
  belongs_to :followed, :class_name => "Channel"

  attr_accessible :followed_id
end
