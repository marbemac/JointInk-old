class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:index,:show,:channels,:check_username,:recommendations]

  def index

  end

  def show
    #TODO: Gross controller

    @user = User.find(request.subdomain.downcase)
    @posts = @user.sharing(@channel).page(params[:page])

    #expires_in 10.seconds, :public => true
    #maximum = @posts.maximum(:updated_at)
    #if stale? etag: [@user, maximum], last_modified: maximum, public: true
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

    if @posts.length == 0
      @channel_suggestions = Channel.popular(5)
    end

    add_page_entity('userViewed', @user)

    respond_to do |format|
      format.html
      format.atom { render :layout => false }
      format.rss { redirect_to user_feed_path(:format => :atom), :status => :moved_permanently }
    end
    #end
  end

  def show_redirect
    @user = User.find(params[:id])
    redirect_to root_url(:subdomain => @user.username), :status => :moved_permanently
  end

  def drafts
    if request.subdomain.blank?
      @user = current_user
    else
      @user = User.find(request.subdomain.downcase)
      authorize! :manage, @user
    end

    @page_title = "Your Ideas"
    @posts = @user.posts.drafts.page(params[:page]).order('created_at DESC')
    add_page_entity('channel', @channel)
  end

  def recommendations
    @user = User.find(request.subdomain.downcase)
    @page_title = @user.name + "'s Recommended Posts"
    @posts = @user.recommendations.page(params[:page])
    add_page_entity('userViewed', @user)
  end

  def settings
    if request.subdomain.blank?
      @user = current_user
    else
      @user = User.find(request.subdomain.downcase)
      authorize! :manage, @user
    end
  end

  def update
    @user = current_user
    authorize! :update, @user

    params[:user][:social_links].reject! {|l| l.blank?} if params[:user][:social_links]

    respond_to do |format|
      current_user.update_attributes(params[:user])
      if current_user.save
        current_user.touch_posts
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
    add_page_entity('userViewed', @user)
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

  # ugggglaayyy
  def dashboard

    if request.subdomain.blank?
      @user = current_user
    else
      @user = User.find(request.subdomain.downcase)
      authorize! :manage, @user
    end

    filter = {:post_user_id => @user.id}
    @post = nil
    if params[:post_id]
      @post = Post.find(params[:post_id])
      filter[:post_id] = params[:post_id]
    end

    @postViews = Stat.retrieve_count('Page View', 30, 'day', filter)
    @postViewsSum = @postViews ? @postViews.inject(0) {|sum, hash| sum + hash['value'].to_i} : 0
    sevenDaySum = @postViews[22..29] ? @postViews[22..29].inject(0) {|sum, hash| sum + hash['value'].to_i} : 0
    previousSevenDaySum = @postViews[15..21] ? @postViews[15..21].inject(0) {|sum, hash| sum + hash['value'].to_i} : 0
    @postViews7DayIncrease =  previousSevenDaySum != 0 ? (((sevenDaySum - previousSevenDaySum).to_f / previousSevenDaySum.to_f) * 100).to_i : '--'

    if @post && @post.post_type == 'picture'
      @postReads = nil
      @postReadsSum = '--'
      @postReads7DayIncrease = '--'
    else
      @postReads = Stat.retrieve_count('Read', 30, 'day', filter)
      @postReadsSum = @postReads ? @postReads.inject(0) {|sum, hash| sum + hash['value'].to_i} : 0
      sevenDaySum = @postReads[22..29] ? @postReads[22..29].inject(0) {|sum, hash| sum + hash['value'].to_i} : 0
      previousSevenDaySum = @postReads[15..21] ? @postReads[15..21].inject(0) {|sum, hash| sum + hash['value'].to_i} : 0
      @postReads7DayIncrease =  previousSevenDaySum != 0 ? (((sevenDaySum - previousSevenDaySum).to_f / previousSevenDaySum.to_f) * 100).to_i : '--'
    end

    @postRecs = Stat.retrieve_count('Recommend', 30, 'day', filter)
    @postRecsSum = @postRecs ? @postRecs.inject(0) {|sum, hash| sum + hash['value'].to_i} : 0
    sevenDaySum = @postRecs[22..29] ? @postRecs[22..29].inject(0) {|sum, hash| sum + hash['value'].to_i} : 0
    previousSevenDaySum = @postRecs[15..21] ? @postRecs[15..21].inject(0) {|sum, hash| sum + hash['value'].to_i} : 0
    @postRecs7DayIncrease =  previousSevenDaySum != 0 ? (((sevenDaySum - previousSevenDaySum).to_f / previousSevenDaySum.to_f) * 100).to_i : '--'

    @referalData = Stat.referal_data(10, 30, filter)

    @posts = @user.posts.active.order('published_at DESC')

    respond_to do |format|
      format.html
      format.json do
        render :partial => 'users/dashboard_post_analytics'
      end
    end
  end

end
