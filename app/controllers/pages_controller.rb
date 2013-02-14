class PagesController < ApplicationController
  layout 'fullscreen_bg', :only => [:home]
  stream

  def home
    @fullscreen = true
    if signed_in?
      redirect_to root_url(:subdomain => current_user.username)
    end
    render :stream => true
  end

end