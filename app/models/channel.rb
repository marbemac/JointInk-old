# == Schema Information
#
# Table name: channels
#
#  cover_photo :string(255)
#  description :string(255)
#  id          :integer          not null, primary key
#  name        :string(255)
#  photo       :string(255)
#  slug        :string(255)
#  status      :string(255)      default("active")
#  user_id     :integer
#

require "limelight"

class Channel < ActiveRecord::Base
  include Limelight::Images

  extend FriendlyId
  friendly_id :name, :use => :slugged

  mount_uploader :photo, ImageUploader

  belongs_to :user, :touch => true
  has_and_belongs_to_many :posts

  validates :user, :presence => true
  validates :name, :presence => true, :length => { :minimum => 2, :maximum => 50 }
  validates :description, :presence => true, :length => { :minimum => 2, :maximum => 200 }
  validates :photo, :presence => true

  attr_accessible :name, :photo, :cover_photo, :description

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
