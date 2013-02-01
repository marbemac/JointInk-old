# == Schema Information
#
# Table name: posts
#
#  audio           :string(255)
#  content         :text
#  created_at      :datetime         not null
#  id              :integer          not null, primary key
#  photo           :string(255)
#  photo_exif      :hstore
#  photo_height    :integer
#  photo_public_id :string(255)
#  photo_width     :integer
#  post_subtype    :string(255)      default("article")
#  post_type       :string(255)      default("text")
#  slug            :string(255)
#  status          :string(255)      default("active")
#  style           :string(255)      default("default")
#  title           :string(255)
#  updated_at      :datetime         not null
#  url             :text
#  user_id         :integer
#  votes_count     :integer          default(0)
#

class Post < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  serialize :photo_exif, ActiveRecord::Coders::Hstore

  extend FriendlyId
  friendly_id :title, :use => :slugged

  mount_uploader :photo, ImageUploader
  mount_uploader :audio, AudioUploader

  belongs_to :user, :touch => true
  has_and_belongs_to_many :channels

  validates :title, :length => {:maximum => 250}
  validates :content, :length => {:maximum => 20000}
  validates :primary_channel, :presence => true, :if => lambda { |post| post.is_active? }
  validates :post_type, :presence => true, :if => lambda { |post| post.is_active? }
  validates :photo, :presence => true, :if => lambda { |post| post.is_active? && post.post_type == 'picture' }

  attr_accessible :title, :content, :photo, :status, :post_type, :post_subtype, :style

  scope :active, where(:status => 'active')
  scope :ideas, where(:status => 'idea')

  before_save :sanitize, :set_published_at
  after_save :touch_channels, :email_after_published
  before_destroy :disconnect

  def is_active?
    status == 'active'
  end

  def disconnect
  end

  def set_published_at
    if status == "active" && published_at.nil?
      self.published_at = Time.now
    end
  end

  def email_after_published
    if status == "active" && published_at_was.nil?
      UserMailer.post_admin(id).deliver
      channels.each do |c|
        unless c.user_id == user_id
          UserMailer.posted_in_channel(id, c.id).deliver
        end
      end
    end
  end

  def touch_channels
    if status_changed?
      channels.each do |c|
        c.calculate_posts_count
      end
    else
      channels.each do |c|
        c.touch
      end
    end
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
                                             :attributes => {
                                                 'a'          => ['href'],
                                             },
                                             :add_attributes => {
                                                 'a' => {'rel' => 'nofollow', 'target' => '_blank'}
                                             }
      )
    end
  end

  def content_clean
    ActionView::Base.full_sanitizer.sanitize(content && !content.blank? ? content.gsub('<p></p>', '').gsub('</p>', '. ').gsub('..', '.') : content)
  end

  def photo_ratio
    if photo.present?
      photo_width.to_f / photo_height.to_f
    else
      0
    end
  end

  def photo_image
    self['photo'] ? self['photo'].split('/').last : nil
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

  def remove_channel(channel)
    ChannelsPosts.where(:post_id => id, :channel_id => channel.id).first.destroy
  end

  def og_title
    title
  end

  def og_description
    truncate(content_clean, :length => 100, :separator => ' ', :omission => '...')
  end

  def og_type
    'article'
  end

  def permalink
    "http://www.getthisthat.com/p/#{id}"
  end

  # has the user voted on this post?
  def voted?(user, request)
    PostStat.retrieve(id, 'vote', request.remote_ip, user ? user.id : nil)
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

  def audio_name
    File.basename(audio.path || audio.filename) if audio
  end

  def update_photo_attributes
    if photo.present?

      public_id = self['photo'].split('/').last.split('.').first
      self.photo_public_id = public_id

      if photo_public_id_changed?
        attributes = Cloudinary::Api.resource(public_id, :exif => true)
        self.photo_width = attributes['width']
        self.photo_height = attributes['height']
        if attributes['exif']
          self.photo_exif = attributes['exif'].slice(
              'ApertureValue',
              'DateTime',
              'ExposureMode',
              'ExposureTime',
              'FNumber',
              'FocalLength',
              'GPSLatitude',
              'GPSLatitudeRef',
              'GPSLongitude',
              'GPSLongitudeRef',
              'ISOSpeedRatings',
              'Make',
              'Model',
              'Orientation',
              'ShutterSpeedValue',
              'XResolution',
              'YResolution'
          )
        end
      end
    end
  end

end
