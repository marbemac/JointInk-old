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
#  origin                 :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  roles                  :string_array(255
#  sign_in_count          :integer          default(0)
#  slug                   :string(255)
#  social_links           :text             default("[]")
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

  delegate :can?, :cannot?, :to => :ability

  serialize :theme_data, ActiveRecord::Coders::Hstore
  serialize :social_links, JSON

  extend FriendlyId
  friendly_id :username, :use => :slugged

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable,# :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :token_authenticatable

  mount_uploader :avatar, ImageUploader
  mount_uploader :cover_photo, ImageUploader

  has_many :posts, :dependent => :destroy
  has_many :relationships, :foreign_key => "follower_id", :dependent => :destroy
  has_many :followed_accounts, :through => :relationships, :source => :followed
  has_many :accounts, :dependent => :destroy
  has_many :channels
  has_many :post_votes

  attr_accessor :login
  attr_accessible :username, :name, :email, :password, :password_confirmation, :remember_me,
                  :login, :bio, :avatar, :cover_photo, :theme_header_color, :theme_header_height,
                  :theme_background_pattern, :email_recommended, :email_channel_post, :email_newsletter,
                  :social_links

  validates :username, :length => { :minimum => 3, :maximum => 15 }, :uniqueness => true
  validates_format_of :username, :with => /^[a-zA-Z][a-zA-Z\d_]*$/, :message => "You must start with a letter, and may only use letters, digits, and underscores"
  validates :name, :length => { :minimum => 3, :maximum => 50 }
  validates :bio, :length => { :maximum => 250, :message => 'Bio has a max length of 250' }
  validate :username_change

  after_create :send_welcome_email, :send_personal_email
  before_destroy :disconnect

  def is_active?
    status == 'active'
  end

  # after destroy, various cleanup
  def disconnect
  end

  def first_name
    name.split(' ').first
  end

  def last_name
    name.split(' ').last
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

  def drafts
    posts.drafts
  end

  def posts_count
    Rails.cache.fetch "#{cache_key}/posts_count" do
      posts.active.count
    end
  end

  def drafts_count
    Rails.cache.fetch "#{cache_key}/drafts_count" do
      posts.drafts.count
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

  def recommendations
    Post.joins(:post_votes).where("post_votes.user_id = ?", id)
  end

  def recommendations_count
    Rails.cache.fetch "#{cache_key}/recommendations_count" do
      recommendations.count
    end
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
    "http://jointink.com/u/#{id}"
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

  # return a specific account
  def account(name, status='active')
    accounts.where(:provider => name, :status => status).first
  end

  def sharing(channel=nil, status='active', params={})
    conditions = {:status => status}
    conditions[:channel_id] = channel.id if channel

    posts.where(conditions).order("published_at DESC")
  end

  def analytics_data(key_prefix=nil)
    data = {
        key_prefix ? "#{key_prefix}Id" : 'id' => id,
        key_prefix ? "#{key_prefix}Email" : 'email' => email,
        key_prefix ? "#{key_prefix}FirstName" : 'firstName' => first_name,
        key_prefix ? "#{key_prefix}LastName" : 'lastName' => last_name,
        key_prefix ? "#{key_prefix}Name" : 'name' => name,
        key_prefix ? "#{key_prefix}Username" : 'username' => username,
        key_prefix ? "#{key_prefix}Created" : 'created' => created_at.iso8601,
        key_prefix ? "#{key_prefix}Birthday" : 'birthday' => birthday ? birthday.iso8601 : nil,
        key_prefix ? "#{key_prefix}Gender" : 'gender' => gender
    }
    data
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

  def self.find_by_request(request)
    if request.host.include?('jointink.com') || request.host.include?('lvh.me')
      find(request.subdomain.downcase)
    else
      find_by_domain(request.host)
    end
  end

  def touch_posts
    posts.update_all(:updated_at => Time.now)
  end

  def ability
    @ability ||= Ability.new(self)
  end

  protected

  # Devise hacks for stub users
  def password_required?
    is_active? && (!persisted? || !password.nil? || !password_confirmation.nil?)
  end

  def email_required?
    is_active?
  end

end
