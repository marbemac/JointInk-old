include ActionView::Helpers::TextHelper
include ActionView::Helpers::AssetTagHelper

class UserMailer < ActionMailer::Base
  layout 'email'#, :except => [:matt_welcome, :marc_welcome]
  default :from => "Joint Ink <team@jointink.com>"
  add_template_helper(ApplicationHelper)

  #def initialize
  #  @image_url = "#{request.protocol}#{request.host_with_port}#{asset_path('joint-ink-logo.gif')}"
  #end

  def welcome_email(user_id)
    @user = User.find(user_id)
    mail(:to => "#{@user.name} <#{@user.email}>", :subject => "#{@user.first_name}, welcome to Joint Ink")
  end

  def welcome_email_admins(user_id)
    user = User.find(user_id)
    mail(:to => 'founders@jointink.com', :reply_to => user.email, :subject => "[Joint Ink signup] #{user.name ? user.name + '(' + user.username + ')' : user.username} signed up!")
  end

  def post_admin(post_id)
    @post = Post.find(post_id)
    mail(:to => "matt.c.mccormick@gmail.com, marbemac@gmail.com", :subject => "New Post: #{@post.title}")
  end

  def posted_in_channel(post_id, channel_id)
    @post = Post.find(post_id)
    @channel = Channel.find(channel_id)
    mail(:to => "#{@channel.user.name} <#{@channel.user.email}>", :subject => "#{@post.user.first_name} posted in your channel!")
  end

  def recommended(post_id, recommender_id)
    @post = Post.find(post_id)
    @user = @post.user
    @recommender = User.find(recommender_id)
    mail(:to => "#{@user.name} <#{@user.email}>", :subject => "#{@user.first_name}, #{@recommender.first_name} recommended your post!")
  end

  #def matt_welcome(user_id)
  #  @user = User.find(user_id)
  #  mail(:from => "Matt <matt@jointink.com>", :to => "#{@user.username} <#{@user.email}>", :subject => "Thanks")
  #end
  #
  #def marc_welcome(user_id, today_or_yesterday)
  #  @user = User.find(user_id)
  #  @today_or_yesterday = today_or_yesterday
  #  mail(:from => "Marc <marc@jointink.com>", :to => "#{@user.username} <#{@user.email}>", :subject => "Hi There")
  #end

  #def pending_reminder(user_id, pending_this_week, crowdsourced_this_week)
  #  @user = User.find(user_id)
  #  @pending_this_week = pending_this_week.to_i
  #  @crowdsourced_this_week = crowdsourced_this_week.to_i
  #  subject = "You have"
  #  subject = subject + " #{pluralize(@user.pending_share_count.to_i, 'pending post') if @user.pending_share_count > 0}"
  #  subject = subject + " and" if @user.pending_share_count > 0 && @crowdsourced_this_week > 0
  #  subject = subject + " #{pluralize(@crowdsourced_this_week, 'auto-organized post')}" if @crowdsourced_this_week > 0
  #  subject = subject + "!"
  #  mail(:to => "#{@user.username} <#{@user.email}>", :subject => subject)
  #end
end