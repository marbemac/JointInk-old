# == Schema Information
#
# Table name: posts
#
#  channel_id   :integer
#  content      :text
#  created_at   :datetime         not null
#  id           :integer          not null, primary key
#  photo        :string(255)
#  photo_height :integer
#  photo_width  :integer
#  post_type    :string(255)
#  slug         :string(255)
#  status       :string(255)      default("active")
#  title        :string(255)
#  updated_at   :datetime         not null
#  url          :text
#  user_id      :integer
#

require "limelight"

class Post < ActiveRecord::Base
  include Limelight::Images

  extend FriendlyId
  friendly_id :title, :use => :slugged

  mount_uploader :photo, ImageUploader

  belongs_to :user, :touch => true
  has_and_belongs_to_many :channels

  validates :title, :length => {:maximum => 250}, :if => lambda { |post| post.is_active? }
  validates :content, :length => {:maximum => 20000}, :if => lambda { |post| post.is_active? }
  validates :primary_channel, :presence => true, :if => lambda { |post| post.is_active? }
  validates :post_type, :presence => true, :if => lambda { |post| post.is_active? }
  validates :photo, :presence => true, :if => lambda { |post| post.is_active? && post.post_type == 'picture' }

  attr_accessible :title, :content, :photo, :status, :post_type, :post_subtype

  scope :active, where(:status => 'active')
  scope :drafts, where(:status => 'draft')

  before_save :sanitize
  before_destroy :disconnect

  def is_active?
    status == 'active'
  end

  def og_type
    og_namespace + ":post"
  end

  def disconnect
  end

  def sanitize
    # remove all tags from title
    if title_changed?
      self.title = ActionView::Base.full_sanitizer.sanitize(title)
    end
    # only allow some tags on content
    if content_changed?
      self.content = Sanitize.clean(content, :elements => ['b','i','strong','em','blockquote','p','br','a','h3','h4','ol','ul','li'],
                                             :protocols => {'a' => {'href' => ['http', 'https', 'mailto']}},
                                             :add_attributes => {
                                                 'a' => {'rel' => 'nofollow', 'target' => '_blank'}
                                             }
      )
    end
  end

  def content_clean
    ActionView::Base.full_sanitizer.sanitize(content)
  end

  def photo_ratio
    if photo.present?
      photo_width.to_f / photo_height.to_f
    else
      0
    end
  end

  def primary_channel
    channels.first
  end

  def add_channel(user, channel)
    relationship = ChannelsPosts.new
    relationship.user = user
    relationship.channel = channel
    relationship.post = self
    relationship.save
  end

  ##########
  # JSON
  ##########

  def mixpanel_data(extra=nil)
    {
            "Post Type" => _type,
            "Post Created At" => created_at,
    }
  end

  def json_video(w=680, h=480, autoplay=nil)
    unless type != 'Video' || embed_html.blank?
      Video.video_embed(sources[0], w, h, nil, nil, embed_html, autoplay)
    end
  end

  ##########
  # END JSON
  ##########

  def self.feed(channel=nil, status='active', params={})
    conditions = {:status => status}
    conditions[:shares][:channel_id] = channel.id if channel

    # Sort by shares over the past X hours
    #score_query = "
    #SELECT COUNT(DISTINCT shares.id)
    #FROM shares
    #WHERE shares.post_id = posts.id AND shares.created_at >= '#{Chronic.parse('4 hours ago')}'
    #"

    # possible alternative scoring algorithm: p / (t + 2)^1.5
    #Post.select('posts.*, ((COUNT(posts.id)) / (extract(epoch from age(posts.created_at)) / 60 / 60 / 60 + 1) ^ 1.5) as score')
    #Post.select("posts.*, (#{score_query}) as score")
    Post.select("posts.*")
      .where(conditions)
      .group('posts.id')
      .order('posts.created_at DESC')
  end

  def update_photo_attributes
    if photo.present?
      self.photo_width = photo.image_width
      self.photo_height = photo.image_height
    end
  end

end
