# == Schema Information
#
# Table name: accounts
#
#  id       :integer          not null, primary key
#  provider :string(255)
#  secret   :string(255)
#  status   :string(255)      default("active")
#  token    :string(255)
#  uid      :string(255)
#  user_id  :integer
#  username :string(255)      not null
#

class Account < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :user
  has_many :shares
  has_many :relationships, :foreign_key => "followed_id", :dependent => :destroy
  has_many :followers, :through => :relationships, :source => :follower

  validates :username, :presence => { :message => 'Account username cannot be blank.' }

  default_scope where(:status => 'active')

  def url
    if user_id
      user_path(user)
    else
      case provider
        when 'facebook'
          "http://www.facebook.com/#{uid}"
        when 'twitter'
          "http://www.twitter.com/#{username}"
      end
    end
  end

  # return the connection object for this account (koala, twitter gem, etc)
  def connect
    case provider
      when 'facebook'
        @social_connect ||= Koala::Facebook::API.new(token)
      when 'twitter'
        @social_connect ||= begin
          twitter = Twitter.configure do |config|
            config.consumer_key = ENV['TWITTER_KEY']
            config.consumer_secret = ENV['TWITTER_SECRET']
            config.oauth_token = token
            config.oauth_token_secret = secret
          end
          begin
            twitter.current_user
          rescue => e
            twitter = nil
          end
          twitter
        end
      else
        nil
    end
  end

  def username
    if provider == 'twitter'
      "@#{self['username']}"
    else
      self['username']
    end
  end

end
