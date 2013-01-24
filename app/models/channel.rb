# == Schema Information
#
# Table name: channels
#
#  cover_photo :string(255)
#  created_at  :datetime
#  description :string(255)
#  id          :integer          not null, primary key
#  name        :string(255)
#  photo       :string(255)
#  privacy     :string(255)      default("public")
#  slug        :string(255)
#  status      :string(255)      default("active")
#  updated_at  :datetime
#  user_id     :integer
#

class Channel < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include CloudinaryHelper

  extend FriendlyId
  friendly_id :name, :use => :slugged

  mount_uploader :photo, ImageUploader

  belongs_to :user, :touch => true
  has_and_belongs_to_many :posts

  validates :user, :presence => true
  validates :name, :presence => true, :length => { :minimum => 2, :maximum => 50 }
  validates :description, :presence => true, :length => { :minimum => 2, :maximum => 200 }
  validates :photo, :presence => true
  validates :privacy, :inclusion => { :in => ['public', 'invite'] }

  attr_accessible :name, :photo, :cover_photo, :description, :privacy

  after_create :add_to_soulmate
  after_update :update_denorms
  before_destroy :remove_from_soulmate, :disconnect

  #
  # SoulMate
  #

  def add_to_soulmate
    #resque.enqueue(SmCreateTopic, id)
  end

  def remove_from_soulmate
    #resque.enqueue(SmDestroyTopic, id)
  end

  def disconnect
    # remove mentions of this channel
    Share.where(:channel => self).each do |share|
      share.unset_channel
      share.save
    end
    # remove mentions of this topic
    Share.where(:channel => self).each do |share|
      share.unset_topic
      share.save
    end
  end

  def photo_image
    self['photo'] ? self['photo'].split('/').last : nil
  end

  def posts_count
    Rails.cache.fetch "#{cache_key}/posts_count" do
      posts.active.count
    end
  end

  def og_title
    name
  end

  def og_description
    truncate(description, :length => 100, :separator => ' ', :omission => '...')
  end

  def og_type
    #TODO: create channel open graph type on facebook, make sure it works
    'channel'
  end

  def permalink
    "http://www.getthisthat.com/c/#{id}"
  end

  ##########
  # JSON
  ##########

  def mixpanel_data(extra=nil)
    {
            "Channel Name" => name,
            "Channel Created At" => created_at
    }
  end

  ##########
  # END JSON
  ##########

  def self.search_or_create(name, creator)
    topic = Channel.where(:name => name).first
    unless topic
      topic = creator.topics.create(:name => name)
    end
    topic
  end

  protected

  def update_denorms
    if name_changed? || slug_changed?
      #resque.enqueue(SmCreateTopic, id)
    end
  end
end
