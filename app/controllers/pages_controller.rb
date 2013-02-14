class PagesController < ApplicationController
  layout 'fullscreen_bg', :only => [:home]

  def home
    @fullscreen = true
    if signed_in?
      redirect_to root_url(:subdomain => current_user.username)
    else
      render
    end
  end

end