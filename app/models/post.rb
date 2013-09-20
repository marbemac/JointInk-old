# == Schema Information
#
# Table name: posts
#
#  attribution_link :string(255)
#  audio            :string(255)
#  content          :text
#  created_at       :datetime         not null
#  emailed_from     :string(255)
#  id               :integer          not null, primary key
#  photo            :string(255)
#  photo_exif       :hstore
#  photo_height     :integer
#  photo_public_id  :string(255)
#  photo_width      :integer
#  post_subtype     :string(255)      default("article")
#  post_type        :string(255)      default("text")
#  published_at     :datetime
#  status           :string(255)      default("active")
#  style            :string(255)      default("default")
#  title            :text
#  token            :string(255)
#  updated_at       :datetime         not null
#  url              :text
#  user_id          :integer
#  votes_count      :integer          default(0)
#

class Post < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include PostHelper

  store_accessor :photo_exif

  mount_uploader :photo, ImageUploader
  mount_uploader :audio, AudioUploader

  belongs_to :user, :touch => true
  has_and_belongs_to_many :channels
  has_many :post_votes

  validates :title, :length => {:maximum => 500}
  validates :title, :presence => true, :if => lambda { |post| post.is_active? }
  validates :content, :length => {:maximum => 20000}
  validates :post_type, :presence => true, :if => lambda { |post| post.is_active? }
  validates :photo, :presence => true, :if => lambda { |post| post.is_active? && (post.post_type == 'picture' || post.style == 'text-on-image') }

  scope :active, -> { where(:status => 'active') }
  scope :published, -> { where(:status => 'active') }
  scope :drafts, -> { where(:status => 'draft') }
  scope :notes, -> { where(:status => 'note') }

  before_create :set_default_style
  before_save :sanitize, :set_published_at
  after_save :touch_channels, :email_after_published
  before_create :generate_token
  before_destroy :disconnect

  def to_param
    "#{token}#{title ? '/' + title[0..40].parameterize : ""}"
  end

  def is_active?
    status == 'active'
  end

  def disconnect
    self.status = 'pending_delete'
    save
  end

  def set_default_style
    if post_type == 'text'
      self.style = 'default-article'
    else
      self.style = 'fit-on-screen'
    end
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
        if c.user_id != user_id && user.email_channel_post
          UserMailer.posted_in_channel(id, c.id).deliver
        end
      end
    end
  end

  def post_style_pretty
    case style
      when 'text-on-image'
        'Text on Image'
      when 'cover-page-article'
        'Cover Page Article'
      when 'large-image-article'
        'Large Image Article'
      when 'fit-on-screen'
        'Fit on Screen'
      when 'cover-screen'
        'Cover Screen'
      else
        'Default Article'
    end
  end

  def channels_count
    Rails.cache.fetch "#{cache_key}/channels_count" do
      channels.active.count
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

  # generate a random token identifier
  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(3)
      break random_token unless Post.where(token: random_token).exists?
    end
  end

  def sanitize
    # remove all tags from title
    if !persisted? || title_changed?
      self.title = ActionView::Base.full_sanitizer.sanitize(title)
    end
    # only allow some tags on content
    if content_changed?
      #self.content = Sanitize.clean(content, :elements => ['b','i','strong','em','blockquote','p','br','a','h3','h4','ol','ul','li','div','img'],
      #                                       :protocols => {'a' => {'href' => ['http', 'https', 'mailto']}},
      #                                       :attributes => {
      #                                           'a'          => ['href'],
      #                                           'div'        => ['class','contenteditable','style','data-value'],
      #                                           'img'        => ['src','width','height']
      #                                       },
      #                                       :add_attributes => {
      #                                           'a' => {'rel' => 'nofollow', 'target' => '_blank'}
      #                                       }
      #)
    end
  end

  def next_post
    return nil unless published_at
    Post.active.where('user_id = ? AND published_at < ?', user_id, published_at).order('published_at DESC').first
  end

  def previous_post
    return nil unless published_at
    Post.active.where('user_id = ? AND published_at > ?', user_id, published_at).order('published_at ASC').first
  end

  # removes images from content
  def content_short
    if content.blank?
      content
    else
      content.gsub /\!\[.*\]\(.*\)/, ''
    end
  end

  # returns content in plain text
  def content_plain
    ActionView::Base.full_sanitizer.sanitize(markdown(content_short))
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

  def primary_channel?
    Rails.cache.fetch "#{cache_key}/primary_channel?" do
      primary_channel ? true : false
    end
  end

  def primary_channel
    channels.first
  end

  def add_channel(user, channel)
    return if channels.include?(channel)
    relationship = ChannelsPosts.new
    relationship.user = user
    relationship.channel = channel
    relationship.post = self
    relationship.save
  end

  def remove_channel(channel)
    ChannelsPosts.where(:post_id => id, :channel_id => channel.id).first.destroy
  end

  def photo_id
    self['photo']
  end

  def og_title
    title
  end

  def og_description
    truncate(content_plain, :length => 100, :separator => ' ', :omission => '...')
  end

  def og_type
    'article'
  end

  def permalink
    "http://joint-ink.com/p/#{token}"
  end

  # has the user voted on this post?
  def voted?(user, request)
    PostVote.retrieve(id, request.remote_ip, user ? user.id : nil)
  end

  ##########
  # JSON
  ##########

  def json_video(w=680, h=480, autoplay=nil)
    unless type != 'Video' || embed_html.blank?
      Video.video_embed(sources[0], w, h, nil, nil, embed_html, autoplay)
    end
  end

  ##########
  # END JSON
  ##########

  def analytics_data(key_prefix=nil)
    data = {
        key_prefix ? "#{key_prefix}Id" : 'id' => id,
        key_prefix ? "#{key_prefix}Status" : 'status' => status,
        key_prefix ? "#{key_prefix}Type" : 'type' => post_type,
        key_prefix ? "#{key_prefix}Subtype" : 'subtype' => post_subtype,
        key_prefix ? "#{key_prefix}Style" : 'style' => style,
        key_prefix ? "#{key_prefix}WithPhoto" : 'withPhoto' => photo.present? ? true : false,
        key_prefix ? "#{key_prefix}Created" : 'created' => created_at.iso8601,
        key_prefix ? "#{key_prefix}PublishedAt" : 'publishedAt' => published_at ? published_at.iso8601 : nil,
        key_prefix ? "#{key_prefix}UserId" : 'userId' => user_id
    }
    data
  end

  def self.feed(channel=nil, status='active', params={})
    conditions = {:status => status}
    conditions[:shares][:channel_id] = channel.id if channel

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
