class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  #def facebook
  #  @user, new_user = User.find_by_omniauth(env["omniauth.auth"], current_user, request.env, session['referer'])
  #
  #  if @user && @user.errors.messages[:base]
  #    flash[:error] = ["There is already a user with that account!"]
  #    redirect_to back_or_default_path(root_path)
  #  elsif @user && @user.persisted?
  #    sign_in_and_redirect @user, :event => :authentication
  #  else
  #    flash[:alert] = ["Woops, you don't have an account yet!", "Please supply a username and email"]
  #    session["devise.facebook_data"] = env["omniauth.auth"].except('extra')
  #    redirect_to signup_path
  #  end
  #end
  #
  #def twitter
  #  @user, new_user = User.find_by_omniauth(env["omniauth.auth"], current_user, request.env, session['referer'])
  #
  #  if @user && @user.errors.messages[:base]
  #    flash[:error] = ["There is already a user with that account!"]
  #    redirect_to back_or_default_path(root_path)
  #  elsif @user && @user.persisted?
  #    sign_in_and_redirect @user, :event => :authentication
  #  else
  #    flash[:alert] = ["Woops, you don't have an account yet!", "Please supply a username and email"]
  #    session["devise.twitter_data"] = env["omniauth.auth"].except('extra')
  #    redirect_to signup_path
  #  end
  #end
end