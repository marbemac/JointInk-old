class PostsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :create_read, :show_redirect]

  def new
    if params[:id]
      @channel = Channel.find(params[:id])
      authorize! :post, @channel
    else
      @channel = nil
    end

    authorize! :create, @post
    @post = current_user.posts.create(:status => 'idea', :post_type => params[:type], :post_subtype => params[:subtype])
    if @channel
      @post.add_channel current_user, @channel
    end

    redirect_to edit_post_url(@post, :subdomain => false)
  end

  def update
    @post = Post.find(params[:id])
    authorize! :update, @post

    respond_to do |format|
      if @post.update_attributes(params[:post])
        @post.update_photo_attributes
        @post.save
        format.html { redirect_to post_via_channel_url(@post.primary_channel, @post, :subdomain => @post.user.username)}
        format.js { render :json => {:post => @post, :url => post_via_channel_url(@post.primary_channel, @post, :subdomain => @post.user.username)} }
      else
        format.html { render action: "edit" }
        format.json { render :json => {:errors => @post.errors}, status: :unprocessable_entity }
      end
    end
  end

  def show
    @post = Post.find(params[:post_id])
    authorize! :read, @post
    @body_class = "#{@post.post_type} #{@post.post_subtype} #{@post.style}"
    @fullscreen = @post.post_type == 'picture' ? true : false
    @channel = @post.primary_channel
    @title = @post.title
    @description = @post.content_clean
    build_og_tags(@post.og_title, @post.og_type, @post.permalink, @post.og_description)
    user_id = current_user ? current_user.id : nil
    PostStat.add(@post.id, request.remote_ip, 'view', request.referer, user_id)
  end

  def show_redirect
    @post = Post.find(params[:id])
    if @post.primary_channel
      redirect_to post_via_channel_path(@post.primary_channel, @post, :subdomain => @post.user.username), :status => :moved_permanently
    else
      redirect_to post_via_channel_path(0, @post, :subdomain => @post.user.username), :status => :moved_permanently
    end
  end

  def edit
    @post = Post.find(params[:id])
    authorize! :update, @post
    @body_class = "#{@post.post_type} #{@post.post_subtype} #{@post.style}"
    @fullscreen = @post.post_type == 'picture' ? true : false
    @editing = true
  end

  def destroy
    @post = Post.find(params[:id])
    authorize! :destroy, @post
    @post.destroy
    respond_to do |format|
      format.html { redirect_to user_url(:subdomain => current_user.username) }
      format.js
    end
  end

  def update_photo
    @post = Post.find(params[:id])
    authorize! :update, @post
    @post.photo = params[:post][:photo]
    @post.save
    @post.update_photo_attributes
    @post.save

    render :json => {:url => @post.photo_url, :class => @post.photo_ratio >= 1.4 ? 'cover-image' : 'contain-image'}
  end

  def remove_photo
    @post = Post.find(params[:id])
    authorize! :update, @post
    @post.remove_photo!
    @post.update_photo_attributes
    @post.save
  end

  def update_audio
    @post = Post.find(params[:id])
    authorize! :update, @post
    @post.audio = params[:post][:audio]
    @post.save
    #@post.update_photo_attributes
    #@post.save

    render :json => {:url => @post.audio_url, :name => @post.audio_name}
  end

  def remove_audio
    @post = Post.find(params[:id])
    authorize! :update, @post
    @post.remove_audio!
    @post.save
    render :json => {:status => 'success'}
  end

  def create_vote
    @post = Post.find(params[:id])

    # can't vote on your own posts
    if @post.user_id == current_user.id
      render :json => {:status => 'error'}, status: :unprocessable_entity
    else
      PostStat.add(@post.id, request.remote_ip, 'vote', request.referer, current_user.id)
      UserMailer.recommended(@post.id, current_user.id).deliver
      render :json => {:status => 'success'}, status: 200
    end
  end

  def destroy_vote
    @post = Post.find(params[:id])

    stat = PostStat.retrieve(@post.id, 'vote', request.remote_ip, current_user.id)
    if stat
      stat.destroy
      render :json => {:status => 'success'}, status: 200
    else
      render :json => {:status => 'error'}, status: :unprocessable_entity
    end
  end

  def create_read
    @post = Post.find(params[:id])
    user_id = current_user ? current_user.id : nil

    if @post.user_id == user_id || @post.status != 'active'
      render :json => {:status => 'success'}, status: 200
    else
      PostStat.add(@post.id, request.remote_ip, 'read', request.referer, user_id)
      render :json => {:status => 'success'}, status: 200
    end
  end

  def add_channel
    @post = Post.find(params[:id])
    authorize! :destroy, @post
    @channel = Channel.find(params[:channel_id])
    authorize! :post, @channel

    respond_to do |format|
      if @post.channels.include?(@channel)
        format.html { redirect_to :back }
        format.js { render :json => {:status => 'error'}, :status => 400 }
      else
        @post.add_channel(current_user, @channel)
        list_item_html = render_to_string('posts/_channels_list_item', :layout => false, :locals => { :channel => @channel })
        format.html { redirect_to :back }
        format.js { render :json => {:status => 'success', :channel => {:id => @channel.id, :name => @channel.name, :list_item => list_item_html}} }
      end
    end
  end

  def remove_channel
    @post = Post.find(params[:id])
    authorize! :destroy, @post
    @channel = Channel.find(params[:channel_id])
    authorize! :post, @channel

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
end