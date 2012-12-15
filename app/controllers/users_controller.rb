class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  def index

  end

  def show
    #TODO: Gross controller

    @user = User.find(params[:id].downcase)
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

    case params[:page]
      when 'posts'
        @posts = @user.sharing(@channel).page(params[:page]).order('created_at DESC')
      when 'feed'
        @posts = @user.feed(@channel).page(params[:page])
    end
  end

  def show_redirect
    @user = User.find(params[:id])
    redirect_to user_path(@user)
  end

  def ideas
    @user = current_user
    @title = "Ideas"
    @page_title = "Your Ideas"
    @posts = @user.posts.ideas.page(params[:page]).to_a
  end

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

  def basic_settings

  end

  def social_settings

  end

  def email_settings

  end

  def update
    respond_to do |format|
      current_user.update_attributes(params[:user])
      if current_user.save
        format.html { redirect_to :back, notice: 'Successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => params[:page] }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def account_deauth
    account = Account.find(params[:id])
    if account.user_id = current_user.id
      account.status = 'disabled'
      account.save
    end
    redirect_to :back, :notice => 'Account successfully removed'
  end

  def signin

  end

  def signup

  end
end
