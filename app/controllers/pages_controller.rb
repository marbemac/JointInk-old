class PagesController < ApplicationController
  layout 'splash_page', :only => [:home]
  caches_action :home, if: lambda { !signed_in? }

  def home
    @fullscreen = true
    @channels = Channel.active.order("posts_count DESC").limit(3)
    if signed_in?
      redirect_to root_url(:subdomain => current_user.username)
    else
      render
    end
  end

  def health_check
    render :text => 'Everything looks A-OK!', :layout => false
  end

end