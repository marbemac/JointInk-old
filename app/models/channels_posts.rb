class ChannelsPosts < ActiveRecord::Base
  belongs_to :user
  belongs_to :channel
  belongs_to :post
end