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
#  roles                  :string_array(255 default("{}")
#  sign_in_count          :integer          default(0)
#  slug                   :string(255)
#  status                 :string(255)      default("active")
#  time_zone              :string(255)      default("Eastern Time (US & Canada)")
#  unconfirmed_email      :string(255)
#  updated_at             :datetime         not null
#  use_fb_image           :boolean          default(FALSE)
#  username               :string(255)
#  username_reset         :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  #include Limelight::Images
  include ActionView::Helpers::TextHelper

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
                  :login, :bio, :avatar, :cover_photo

  validates :username, :length => { :minimum => 3, :maximum => 15 }, :uniqueness => true
  validates :name, :length => { :minimum => 3, :maximum => 50 }
  validates :bio, :length => { :maximum => 250, :message => 'Bio has a max length of 250' }
  validate :username_change

  after_create :add_to_soulmate, :send_personal_email
  after_update :update_denorms
  before_destroy :remove_from_soulmate, :disconnect

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

  def drafts
    posts.where(:status => 'draft')
  end

  ###
  # ROLES
  ###

  # Checks to see if this user has a given role
  def role?(role)
    roles.include? role
  end

  # Adds a role to this user
  def grant_role(role)
    self.roles << role unless self.roles.include?(role)
  end

  # Removes a role from this user
  def revoke_role(role)
    self.roles.delete(role)
  end

  def add_to_soulmate
    #resque.enqueue(SmCreateUser, id) if is_active?
  end

  def remove_from_soulmate
    #resque.enqueue(SmDestroyUser, id)
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

  def created_channels
    @created_channels ||= Channel
      .includes(:posts)
      .where("channels.user_id = ? AND channels.status = ?", id, 'active')
      .uniq
  end

  def contributed_channels
    @contributed_channels ||= Channel
      .includes(:posts)
      .where("channels.user_id != ? AND channels.status = ? AND posts.user_id = ? AND posts.status = ?", id, 'active', id, 'active')
      .uniq
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
      user.send_welcome_email
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
