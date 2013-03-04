class PagesController < ApplicationController
  layout 'fullscreen_bg', :only => [:home]

  def home
    @fullscreen = true
    @channels = Channel.active.order("posts_count DESC").limit(3)
    if signed_in?
      redirect_to root_url(:subdomain => current_user.username)
    else
      render
    end
  end

end