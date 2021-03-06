class PostsController < ApplicationController
  before_action :authenticate_user!, :except => [:active_user, :show, :create_read, :show_redirect, :create_vote, :destroy_vote]
  include PostHelper

  def active_user
    @post = Post.where(:token => params[:id]).first
    not_found unless @post
    stale? etag: [@post, (current_user ? current_user : request.remote_ip)]
  end

  def new
    if params[:id] # This is a channel id because Marc doesn't know how parameter labels work
      @channel = Channel.find(params[:id])
      authorize! :post, @channel
    else
      @channel = nil
    end

    authorize! :create, @post
    @post = current_user.posts.create(:status => 'draft', :post_type => params[:type], :post_subtype => params[:subtype])
    set_session_analytics("Start Post", {:postId => @post.id})
    if @channel
      @post.add_channel current_user, @channel
    end

    redirect_to edit_post_url(@post, :subdomain => false)
  end

  def update
    @post = Post.where(:token => params[:id]).first
    authorize! :update, @post
    pub = @post.published_at

    respond_to do |format|
      if @post.update_attributes(post_params)
        set_session_analytics("Publish", {:postId => @post.id}) if !pub && @post.published_at # Not super clean, but it works
        @post.update_photo_attributes
        @post.save

        format.html { redirect_to (@post.primary_channel ? post_via_channel_url(@post.primary_channel, @post, :subdomain => @post.user.username) : post_url(@post, :subdomain => @post.user.username)), :notice =>"Post Updated"}
        format.js { render :json => {:post => @post, :url => @post.primary_channel ? post_via_channel_url(@post.primary_channel, @post, :subdomain => @post.user.username) : post_url(@post, :subdomain => @post.user.username)} }
      else
        format.html { render action: "edit" }
        format.json { render :json => {:errors => @post.errors.full_messages}, status: :unprocessable_entity }
      end
    end
  end

  def show
    @post = Post.where(:token => params[:post_id]).first
    not_found unless @post
    authorize! :read, @post

    expires_in 60.seconds, :public => true
    if stale? etag: @post, last_modified: @post.updated_at, public: true
      @channel = @post.primary_channel
      @title = @post.title
      @description = @post.og_description
      build_og_tags(@post.og_title, @post.og_type, post_pretty_url(@post), @post.og_description)

      add_page_entity('channel', @channel)
      add_page_entity('post', @post)
    end
  end

  def show_redirect
    @post = Post.where(:token => params[:id]).first
    if @post.primary_channel
      redirect_to post_via_channel_url(@post.primary_channel, @post, :subdomain => @post.user.username), :status => :moved_permanently
    else
      redirect_to post_via_channel_url(0, @post, :subdomain => @post.user.username), :status => :moved_permanently
    end
  end

  def edit
    if request.subdomain.blank?
      @user = current_user
    else
      @user = User.find(request.subdomain.downcase)
      authorize! :manage, @user
    end

    @posts = @user.posts.order('created_at DESC')

    if params[:id]
      @post = Post.where(:token => params[:id]).first
    else
      @post = @posts.first
    end

    authorize! :update, @post
  end

  def stats
    if request.subdomain.blank?
      @user = current_user
    else
      @user = User.find(request.subdomain.downcase)
      authorize! :manage, @user
    end

    filter = {:post_user_id => @user.id}
    @post = nil
    if params[:id]
      @post = Post.where(:token => params[:id]).first
      filter[:post_id] = @post.id
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

    @posts = @user.posts.order('created_at DESC')
  end

  def destroy
    @post = Post.where(:token => params[:id]).first
    authorize! :destroy, @post
    @post.destroy
    respond_to do |format|
      format.html { redirect_to user_dashboard_url(:subdomain => nil) }
      format.js
    end
  end

  def add_inline_photo
    @post = Post.where(:token => params[:id]).first
    authorize! :update, @post
    photo = Cloudinary::Uploader.upload(post_params[:photo], {:tags => ["post-#{@post.id}"], :format => 'jpg', :transformation => {:crop => :limit, :width => 1400, :height => 1400, :quality => 80}})
    url = Cloudinary::Utils.cloudinary_url("v#{photo['version']}/#{photo['public_id']}.jpg", {:crop => :limit, :width => 700})
    render :text => "{\"url\" : \"#{url}\", \"photo\" : \"v#{photo['version']}/#{photo['public_id']}.jpg\", \"id\" : \"#{photo['public_id']}\"}", :content_type => "text/plain"
  end

  def update_photo
    @post = Post.where(:token => params[:id]).first
    authorize! :update, @post
    @post.photo = post_params[:photo]
    @post.save
    @post.update_photo_attributes
    @post.save

    render :text => "{\"url\" : \"#{@post.photo_url}\"}", :content_type => "text/plain"
  end

  def remove_photo
    @post = Post.where(:token => params[:id]).first
    authorize! :update, @post
    @post.remove_photo!
    @post.update_photo_attributes
    @post.save
  end

  def update_audio
    @post = Post.where(:token => params[:id]).first
    authorize! :update, @post
    @post.audio = post_params[:audio]
    @post.save

    render :json => {:url => @post.audio_url, :name => @post.audio_name}
  end

  def remove_audio
    @post = Post.where(:token => params[:id]).first
    authorize! :update, @post
    @post.remove_audio!
    @post.save
    render :json => {:status => 'success'}
  end

  def create_vote
    @post = Post.where(:token => params[:id]).first

    # can't vote on your own posts
    if current_user && @post.user_id == current_user.id
      render :json => {:status => 'error'}, status: :unprocessable_entity
    else
      PostVote.add(@post.id, request.remote_ip, current_user ? current_user.id : nil)
      Stat.create_from_page_analytics('Recommend', current_user, [@post], (params[:referrer] && !params[:referrer].blank? ? params[:referrer] : nil), request.remote_ip)
      current_user.touch if current_user
      if current_user && current_user.email_recommended
        UserMailer.recommended(@post.id, current_user.id).deliver
      end
      render :json => {:status => 'success', :votes_count => @post.votes_count + 1}, status: 200
    end
  end

  def destroy_vote
    @post = Post.where(:token => params[:id]).first

    stat = PostVote.retrieve(@post.id, request.remote_ip, current_user ? current_user.id : nil)
    if stat
      stat.destroy
      Stat.create_from_page_analytics('Remove Recommend', current_user, [@post], (params[:referrer] && !params[:referrer].blank? ? params[:referrer] : nil), request.remote_ip)
      current_user.touch if current_user
      render :json => {:status => 'success', :votes_count => @post.votes_count - 1}, status: 200
    else
      render :json => {:status => 'error'}, status: :unprocessable_entity
    end
  end

  def add_channel
    @post = Post.where(:token => params[:id]).first
    authorize! :destroy, @post
    @channel = Channel.find(params[:channel_id])
    authorize! :post, @channel

    respond_to do |format|
      if @post.channels.include?(@channel)
        format.html { redirect_to :back }
        format.js { render :json => {:status => 'error'}, :status => 400 }
      else
        @post.add_channel(current_user, @channel)
        list_item_html = render_to_string('posts/_channels_list_item', :layout => false, :locals => { :channel => @channel, :remove_link => true })
        format.html { redirect_to :back }
        format.js { render :json => {:status => 'success', :channel => {:id => @channel.id, :name => @channel.name, :list_item => list_item_html}} }
      end
    end
  end

  def remove_channel
    @post = Post.where(:token => params[:id]).first
    authorize! :destroy, @post
    @channel = Channel.find(params[:channel_id])

    respond_to do |format|
      if @post.channels.include?(@channel)
        @post.remove_channel(@channel)
        format.html { redirect_to :back }
        format.js { render :json => {:status => 'success'} }
      else
        format.html { redirect_to :back }
        format.js { render :json => {:status => 'error'}, :status => 400 }
      end
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :photo, :status, :post_type, :post_subtype, :style, :attribution_link)
  end

end