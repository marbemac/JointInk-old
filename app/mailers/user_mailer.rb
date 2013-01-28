include ActionView::Helpers::TextHelper

class UserMailer < ActionMailer::Base
  layout 'email', :except => [:matt_welcome, :marc_welcome]
  default :from => "ThisThat <founders@getthisthat.com>"

  def welcome_email(user_id)
    @user = User.find(user_id)
    mail(:to => "#{@user.name} <#{@user.email}>", :subject => "#{@user.first_name}, welcome to ThisThat")
  end

  def welcome_email_admins(user_id)
    user = User.find(user_id)
    mail(:to => 'founders@getthisthat.com', :reply_to => user.email, :subject => "[ThisThat signup] #{user.name ? user.name + '(' + user.username + ')' : user.username} signed up!")
  end

  #def matt_welcome(user_id)
  #  @user = User.find(user_id)
  #  mail(:from => "Matt <matt@getthisthat.com>", :to => "#{@user.username} <#{@user.email}>", :subject => "Thanks")
  #end
  #
  #def marc_welcome(user_id, today_or_yesterday)
  #  @user = User.find(user_id)
  #  @today_or_yesterday = today_or_yesterday
  #  mail(:from => "Marc <marc@getthisthat.com>", :to => "#{@user.username} <#{@user.email}>", :subject => "Hi There")
  #end

  def pending_reminder(user_id, pending_this_week, crowdsourced_this_week)
    @user = User.find(user_id)
    @pending_this_week = pending_this_week.to_i
    @crowdsourced_this_week = crowdsourced_this_week.to_i
    subject = "You have"
    subject = subject + " #{pluralize(@user.pending_share_count.to_i, 'pending post') if @user.pending_share_count > 0}"
    subject = subject + " and" if @user.pending_share_count > 0 && @crowdsourced_this_week > 0
    subject = subject + " #{pluralize(@crowdsourced_this_week, 'auto-organized post')}" if @crowdsourced_this_week > 0
    subject = subject + "!"
    mail(:to => "#{@user.username} <#{@user.email}>", :subject => subject)
  end
end