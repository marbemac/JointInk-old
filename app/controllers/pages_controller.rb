class PagesController < ApplicationController
  layout 'splash_page', :only => [:home]
  include UserHelper
  #caches_action :home, if: lambda { !user_signed_in? }

  def home
    #expires_in 3.hours, :public => true

    if user_signed_in?
      redirect_to user_pretty_url(current_user)
    else
      @fullscreen = true
      @channels = Channel.active.order("posts_count DESC").limit(3)
      render
    end
  end

  def health_check
    render :text => "Everything looks A-OK!", :layout => false
  end

  def debug
    render :layout => false
  end

end