class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:index,:show,:channels,:check_username]

  def index

  end

  def show
    #TODO: Gross controller

    @user = User.find(request.subdomain.downcase)
    @title = @user.name + "'s Posts"
    @page_title = @user.name

    @page = params[:page]
    @channel = nil
    if params[:channel_id]
      @channel = Channel.find(params[:channel_id])
      @title += ' in ' + @channel.name
    end
    @description = @user.bio
    build_og_tags(@user.og_title, @user.og_type, @user.permalink, @user.og_description)

    @posts = @user.sharing(@channel).page(params[:page]).order('created_at DESC')

    if @posts.length == 0
      @channel_suggestions = Channel.popular(5)
    end
  end

  def show_redirect
    @user = User.find(params[:id])
    redirect_to root_url(:subdomain => @user.username), :status => :moved_permanently
  end

  def ideas
    @user = User.find(request.subdomain.downcase)
    authorize! :update, @user
    @page_title = "Your Ideas"
    @posts = @user.posts.ideas.page(params[:page]).order('created_at DESC')
  end

  def recommendations
    @user = User.find(request.subdomain.downcase)
    @page_title = @user.name + "'s Recommended Posts"
    @posts = @user.recommendations.page(params[:page])
  end

  def settings
    @user = current_user
  end

  def update
    @user = current_user
    authorize! :update, @user

    params[:user][:social_links].reject! {|l| l.blank?} if params[:user][:social_links]

    respond_to do |format|
      current_user.update_attributes(params[:user])
      if current_user.save
        format.html { redirect_to :back, notice: 'Successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => 'settings' }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def channels
    @user = User.find(request.subdomain.downcase)
  end

  def signin

  end

  def signup

  end

  def check_username
    user = User.where(:slug => params[:username].downcase).first
    if user
      render json: {:status => :ok, :available => false}
    else
      render json: {:status => :ok, :available => true}
    end
  end

  # not currently in use
  def add
    @user = User.find(params[:user_id])
    @channel = params[:channel_id] ? Channel.find(params[:channel_id]) : nil

    authorize! :update, @user
    authorize! :read, @channel

    current_user.add(@user, @channel)

    respond_to do |format|
      format.html {
        redirect_to :back, :notice => "#{@user.name} successfully added to your feed."
      }
    end
  end

  # not currently in use
  def remove
    @user = User.find(params[:user_id])
    @channel = params[:channel_id] ? Channel.find(params[:channel_id]) : nil

    authorize! :update, @user
    authorize! :read, @channel

    current_user.remove(@user, @channel)

    respond_to do |format|
      format.html {
        redirect_to :back, :notice => "#{@user.name} successfully remove from your feed."
      }
    end
  end

  # not currently in use
  def account_deauth
    account = Account.find(params[:id])
    if account.user_id = current_user.id
      account.status = 'disabled'
      account.save
    end
    redirect_to :back, :notice => 'Account successfully removed'
  end

end
