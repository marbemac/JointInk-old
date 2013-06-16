# == Schema Information
#
# Table name: channels
#
#  cover_photo :string(255)
#  created_at  :datetime
#  description :string(255)
#  email       :string(255)
#  id          :integer          not null, primary key
#  info        :text
#  name        :string(255)
#  photo       :string(255)
#  posts_count :integer          default(0)
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
  mount_uploader :cover_photo, ImageUploader

  belongs_to :user, :touch => true
  has_and_belongs_to_many :posts

  validates :user, :presence => true
  validates :name, :presence => true, :length => { :minimum => 2, :maximum => 100 }, :uniqueness => true
  validates :description, :length => { :maximum => 200 }
  validates :privacy, :inclusion => { :in => ['public', 'invite'] }
  validates :email, :length => { :minimum => 2, :maximum => 200 }, :uniqueness => true
  validates_format_of :email, :with => /^[a-zA-Z][a-zA-Z\d_]*$/, :message => "You must start with a letter, and may only use letters, digits, and underscores"
  validates_exclusion_of :email, :in => %w(draft drafts publish published www note notes user help team tech admin marc matt atif founders info contact hello hi),
                         :message => "Email {{value}} is not available."

  attr_accessible :name, :photo, :cover_photo, :description, :privacy, :info, :email

  scope :active, where(:status => 'active')
  scope :public, where(:privacy => 'public')
  scope :private, where(:privacy => 'invite')
  scope :with_posts, where('channels.posts_count > 0')

  before_destroy :disconnect

  include PgSearch
  pg_search_scope :search,
                  against: {
                    :name => 'A',
                    :description => 'B'
                  },
                  using: {
                      tsearch: {
                          prefix: true,
                          #dictionary: 'english'
                      }
                  }

  def self.text_search(query)
    if query.present?
      search(query)
    else
      active.limit(10)
    end
  end

  def self.to_search_json(results)
    results.map do |result|
      {
          :value => result.name,
          :data => {
              :id => result.id,
              :description => result.description
          }
      }
    end
  end

  def calculate_posts_count
    self.posts_count = posts.active.count
    save
  end

  def disconnect

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
    "http://jointink.com/c/#{id}"
  end

  def analytics_data(key_prefix=nil)
    data = {
        key_prefix ? "#{key_prefix}Id" : 'id' => id,
        key_prefix ? "#{key_prefix}Status" : 'status' => status,
        key_prefix ? "#{key_prefix}Privacy" : 'privacy' => privacy,
        key_prefix ? "#{key_prefix}Created" : 'created' => (created_at ? created_at.iso8601 : nil),
        key_prefix ? "#{key_prefix}UserId" : 'userId' => user_id
    }
    data
  end

  def self.popular(limit=10)
    Channel.active.public.joins(:posts).select("channels.*, COUNT(posts.id) as counter").group("channels.id").order("counter DESC").limit(limit)
  end

  def self.search_or_create(name, creator)
    topic = Channel.where(:name => name).first
    unless topic
      topic = creator.topics.create(:name => name)
    end
    topic
  end

  def touch_posts
    posts.update_all(:updated_at => Time.now)
  end

  protected


end
