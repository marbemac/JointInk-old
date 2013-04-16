# == Schema Information
#
# Table name: users
#
#  authentication_token   :string(255)
#  avatar                 :string(255)
#  bio                    :text
#  birthday               :date
#  confirmation_sent_at   :datetime
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  cover_photo            :string(255)
#  created_at             :datetime         not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  domain                 :string(255)
#  email                  :string(255)
#  email_channel_post     :boolean          default(TRUE)
#  email_newsletter       :boolean          default(TRUE)
#  email_recommended      :boolean          default(TRUE)
#  encrypted_password     :string(255)      default(""), not null
#  gender                 :string(255)
#  id                     :integer          not null, primary key
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  name                   :string(255)
#  oneliner               :string(255)
#  origin                 :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  roles                  :string_array(255
#  sign_in_count          :integer          default(0)
#  slug                   :string(255)
#  status                 :string(255)      default("active")
#  theme_data             :hstore
#  time_zone              :string(255)      default("Eastern Time (US & Canada)")
#  unconfirmed_email      :string(255)
#  updated_at             :datetime         not null
#  use_fb_image           :boolean          default(FALSE)
#  username               :string(255)
#  username_reset         :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  serialize :theme_data, ActiveRecord::Coders::Hstore
  serialize :social_links, JSON

  extend FriendlyId
  friendly_id :username, :use => :slugged

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :token_authenticatable

  mount_uploader :avatar, ImageUploader
  mount_uploader :cover_photo, ImageUploader

  has_many :posts, :dependent => :destroy
  has_many :relationships, :foreign_key => "follower_id", :dependent => :destroy
  has_many :followed_accounts, :through => :relationships, :source => :followed
  has_many :accounts, :dependent => :destroy
  has_many :channels

  attr_accessor :login
  attr_accessible :username, :name, :email, :password, :password_confirmation, :remember_me,
                  :login, :bio, :avatar, :cover_photo, :theme_header_color, :theme_header_height,
                  :theme_background_pattern, :email_recommended, :email_channel_post, :email_newsletter,
                  :social_links

  validates :username, :length => { :minimum => 3, :maximum => 15 }, :uniqueness => true
  validates :name, :length => { :minimum => 3, :maximum => 50 }
  validates :bio, :length => { :maximum => 250, :message => 'Bio has a max length of 250' }
  validate :username_change

  before_create :set_theme
  after_create :send_welcome_email, :send_personal_email
  after_update :update_denorms
  before_destroy :disconnect

  # START THEMES
  def set_theme
    self.theme_header_color = %w(#8C2300 #661A00 #8C4600 #B25900 #698C00 #4C6600 #1A6600 #00661A #008C46
                            #00664C #006666 #008C8C #00698C #004C66 #003366 #00468C #001A66 #1A0066 #46008C #660066 #660066
                            #8A8A7B #79796A #686859 #646473 #313140).sample
    self.theme_background_pattern = 'cross_scratches.png'
  end

  def theme_header_color=(color)
    self.theme_data ||= {}
    self.theme_data['header_color'] = color
  end

  def theme_header_color
    theme_data['header_color']
  end

  def theme_header_height=(height)
    self.theme_data ||= {}
    self.theme_data['header_height'] = height
  end

  def theme_header_height
    theme_data['header_height']
  end

  def theme_background_pattern=(pattern)
    self.theme_data ||= {}
    self.theme_data['background_pattern'] = pattern
  end

  def theme_background_pattern_path
    "backgrounds/#{theme_background_pattern}"
  end

  def theme_background_pattern
    theme_data['background_pattern']
  end

  def self.theme_background_patterns
    [
        'cross_scratches.png','escheresque_ste.png','black_lozenge.png','kindajean.png','tileable_wood_texture.png','paper_fibers.png','dark_fish_skin.png','pw_maze_white.png',
        'subtle_zebra_3d.png','texturetastic_gray.png','purty_wood.png','classy_fabric.png','vintage_speckles.png','vertical_cloth.png','darkdenim3.png','subtle_grunge.png',
        'gray_jean.png','linedpaper.png','white_wall2.png','creampaper.png','debut_dark.png','debut_light.png','scribble_light.png','clean_textile.png','gplaypattern.png',
        'weave.png','lil_fiber.png','white_tiles.png','tex2res5.png','tex2res3.png','tex2res4.png','lghtmesh.png','hexellence.png','dark_Tire.png','frenchstucco.png',
        'light_wool.png','rough_diagonal.png','daimond_eyes.png','honey_im_subtle.png','furley_bg.png','blizzard.png','farmer.png','satinweave.png','dark_matter.png',
        'fabric_plaid.png','irongrip.png','foggy_birds.png','denim.png','wood_pattern.png','ravenna.png','nasty_fabric.png','otis_redding.png','wild_oliva.png',
        'connect.png','old_wall.png','px_by_Gre3g.png','diagmonds.png','polonez_car.png','dark_wood.png','project_papper.png','green-fibers.png','bright_squares.png',
        'wood_1.png'
    ]
  end
  # END THEMES

  def is_active?
    status == 'active'
  end

  # after destroy, various cleanup
  def disconnect
  end

  def first_name
    name.split(' ').first
  end

  def avatar_image
    self['avatar'] ? self['avatar'].split('/').last : nil
  end

  def username_change
    if username_was && username_changed? && username_was != username
      if username_reset == false && !role?('admin')
        errors.add(:username, "Username cannot be changed right now")
      else
        self.username_reset = false
      end
    end
  end

  def ideas
    posts.ideas
  end

  def posts_count
    Rails.cache.fetch "#{cache_key}/posts_count" do
      posts.active.count
    end
  end

  def ideas_count
    Rails.cache.fetch "#{cache_key}/ideas_count" do
      posts.ideas.count
    end
  end

  def channels_count
    created_channels_count + contributed_channels_count
  end

  def created_channels_count
    Rails.cache.fetch "#{cache_key}/created_channels_count" do
      created_channels.count
    end
  end

  def contributed_channels_count
    Rails.cache.fetch "#{cache_key}/contributed_channels_count" do
      contributed_channels.count
    end
  end

  def created_channels
    @created_channels ||= Channel
    .where("channels.user_id = ? AND channels.status = ?", id, 'active')
    .uniq
  end

  def contributed_channels
    @contributed_channels ||= Channel
    .includes(:posts)
    .where("channels.user_id != ? AND channels.status = ? AND posts.user_id = ? AND posts.status = ?", id, 'active', id, 'active')
    .uniq
  end

  ###
  # ROLES
  ###

  # Checks to see if this user has a given role
  def role?(role)
    roles && roles.include?(role)
  end

  # Adds a role to this user
  def grant_role(role)
    self.roles ||= []
    self.roles << role unless self.roles.include?(role)
  end

  # Removes a role from this user
  def revoke_role(role)
    self.roles.delete(role) if roles
  end

  def send_welcome_email
    if is_active?
      UserMailer.welcome_email(id).deliver
      UserMailer.welcome_email_admins(id).deliver
    end
  end

  def send_personal_email
    if is_active?
      hour = Time.now.hour
      variation = rand(7200)
      if hour < 11
        delay = Chronic.parse('Today at 11AM').to_i - Time.now.utc.to_i + variation
        #resque.enqueue_in(delay, SendPersonalWelcome, id, "today")
      elsif hour >= 11 && hour < 18
        #resque.enqueue_in(1.hours + variation, SendPersonalWelcome, id, "today")
      else
        delay = Chronic.parse('Tomorrow at 11AM').to_i - Time.now.utc.to_i + variation
        #resque.enqueue_in(delay, SendPersonalWelcome, id, "yesterday")
      end
    end
  end

  def deauth_account(provider)
    target = account(provider)
    target.status = 'disabled' if target
    target.save
  end

  def fbuid
    account = account('facebook')
    account.uid if account
  end

  def twuid
    account = account('twitter')
    account.uid if account
  end

  def facebook
    @fb_user ||= begin
      account = account('facebook')
      account ? account.connect : nil
    end
  end

  def twitter
    @twitter_user ||= begin
      account = account('twitter')
      account ? account.connect : nil
    end
  end

  def og_title
    name
  end

  def og_description
    truncate(bio, :length => 100, :separator => ' ', :omission => '...')
  end

  def og_type
    'user'
  end

  def permalink
    "http://www.getthisthat.com/u/#{id}"
  end

  #################
  # ADDING/REMOVING
  #################

  def follows?(user, channel)
    account = user.account('thisthat')
    if account
      Relationship.where(:follower_id => id, :followed_id => account.id, :channel_id => channel.id).first ? true : false
    else
      false
    end
  end

  # add a user / channel to this users feed
  def add(user, channel)
    account = user.account('thisthat')
    if account && !follows?(user, channel)
      relationships.create(:followed_id => account.id, :channel_id => channel.id)
    end
  end

  # remove a user / channel to this users feed
  def remove(user, channel)
    account = user.account('thisthat')
    if account && follows?(user, channel)
      target = relationships.where(:followed_id => account.id, :channel_id => channel.id).first
      target.destroy if target
    end
  end

  ##########
  # JSON
  ##########

  def mixpanel_data(extra=nil)
    {
            :distinct_id => id,
            "User#{extra if extra} Username" => username,
            "User#{extra if extra} Birthday" => birthday,
            "User#{extra if extra} accounted Twitter?" => twuid ? true : false,
            "User#{extra if extra} accounted Facebook?" => fbuid ? true : false,
            "User#{extra if extra} Origin" => origin,
            "User#{extra if extra} Status" => status,
            "User#{extra if extra} Sign Ins" => sign_in_count,
            "User#{extra if extra} Last Sign In" => current_sign_in_at,
            "User#{extra if extra} Created At" => created_at,
            "User#{extra if extra} Confirmed At" => confirmed_at
    }
  end

  # return a specific account
  def account(name, status='active')
    accounts.where(:provider => name, :status => status).first
  end

  def sharing(channel=nil, status='active', params={})
    conditions = {:status => status}
    conditions[:channel_id] = channel.id if channel

    posts.where(conditions).order("created_at DESC")
  end

  ##########
  # END JSON
  ##########

  # Omniauth providers
  def self.find_by_omniauth(omniauth, signed_in_resource=nil, request_env=nil, referer=nil)
    new_user = false
    new_account = false
    login = false
    info = omniauth['info']
    extra = omniauth['extra']['raw_info']

    existing_user = User.joins(:accounts).where('accounts.provider' => omniauth['provider'], "accounts.uid" => omniauth['uid']).readonly(false).first
    # Try to get via email if user not found and email provided
    unless existing_user || !info['email']
      existing_user = User.where(:email => info['email']).first
    end

    if signed_in_resource && existing_user && signed_in_resource != existing_user
      user = signed_in_resource
      user.errors[:base] << "There is already a user with that account"
      return user, new_user
    elsif signed_in_resource
      user = signed_in_resource
    elsif existing_user
      user = existing_user
    end

    account = Account.unscoped.where(:provider => omniauth['provider'], :uid => omniauth['uid']).first

    # If we found the user, update their token
    if user
      # Is this a new account?
      if account
        account.status = 'active'
        account.user = user
      else
        new_account = true
        account = user.accounts.build(:username => info['nickname'] && omniauth['provider'] != 'facebook' ? info['nickname']  : "#{extra["first_name"]} #{extra["last_name"]}", :uid => omniauth["uid"], :provider => omniauth['provider'])
        account.secret = omniauth['credentials']['secret'] if omniauth['credentials'].has_key?('secret')
      end

      # Update the token
      account.token = omniauth['credentials']['token']

      unless signed_in_resource
        login = true
      end

    else
      new_user = true
      if extra["gender"] && !extra["gender"].blank?
        gender = extra["gender"] == 'male' || extra["gender"] == 'm' ? 'm' : 'f'
      else
        gender = nil
      end

      user = User.new(
          :username => info['nickname'] ? info['nickname']  : "#{extra["first_name"]} #{extra["last_name"]}",
          :name => "#{extra["first_name"]} #{extra["last_name"]}",
          :gender => gender, :email => info["email"], :password => Devise.friendly_token[0,20]
      )
      user.birthday = Chronic.parse(extra["birthday"]) if extra["birthday"]
      user.origin = omniauth['provider']

      if account
        account.user = user
      else
        new_account = true
        account = user.accounts.build(:username => info['nickname'] && omniauth['provider'] != 'facebook' ? info['nickname']  : "#{extra["first_name"]} #{extra["last_name"]}", :uid => omniauth["uid"], :provider => omniauth['provider'], :token => omniauth['credentials']['token'])
      end
      account.secret = omniauth['credentials']['secret'] if omniauth['credentials'].has_key?('secret')

    end

    if user && !user.confirmed?
      user.confirm!
    end

    # update the users primary twitter handle
    if account && account.provider == 'twitter'
      begin
        user.twitter_handle = user.twitter.current_user.screen_name
      rescue => e
        user.twitter_handle = nil
      end
    end

    user.save if user
    account.save if account

    if new_user && request_env
      referer_hash = { "Referer" => referer, "Referer Host" => referer == "none" ? "none" : URI(referer).host }
      #resque.enqueue(MixpanelTrackEvent, "Signup", user.mixpanel_data.merge!(referer_hash), request_env.select{|k,v| v.is_a?(String) || v.is_a?(Numeric) })
    end

    if login == true && request_env
      #resque.enqueue(MixpanelTrackEvent, "Login", user.mixpanel_data.merge!("Login Method" => omniauth['provider']), request_env.select{|k,v| v.is_a?(String) || v.is_a?(Numeric) })
    end

    return user, new_user
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      self.where("lower(username) = ? OR lower(email) = ?", login.downcase, login.downcase).first
    else
      super
    end
  end

  protected

  # Devise hacks for stub users
  def password_required?
    is_active? && (!persisted? || !password.nil? || !password_confirmation.nil?)
  end

  def email_required?
    is_active?
  end

  def update_denorms
    if username_changed? || status_changed?
      #resque.enqueue(SmCreateUser, id)
    end
  end

end
