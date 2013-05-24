class PostsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :create_read, :show_redirect, :create_vote, :destroy_vote]
  include PostHelper

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
    @post = Post.find_by_token(params[:id])
    authorize! :update, @post
    pub = @post.published_at

    respond_to do |format|
      if @post.update_attributes(params[:post])
        set_session_analytics("Publish", {:postId => @post.id}) if !pub && @post.published_at # Not super clean, but it works
        @post.update_photo_attributes
        @post.save

        format.html { redirect_to (@post.primary_channel ? post_via_channel_url(@post.primary_channel, @post, :subdomain => @post.user.username) : post_url(@post, :subdomain => @post.user.username)), :notice =>"Post Updated"}
        format.js { render :json => {:post => @post, :url => @post.primary_channel ? post_via_channel_url(@post.primary_channel, @post, :subdomain => @post.user.username) : post_url(@post, :subdomain => @post.user.username)} }
      else
        format.html { render action: "edit" }
        format.json { render :json => {:errors => @post.errors}, status: :unprocessable_entity }
      end
    end
  end

  def show
    @post = Post.find_by_token(params[:post_id])
    authorize! :read, @post
    @body_class = "#{@post.post_type} #{@post.post_subtype} #{@post.style}"
    @fullscreen = @post.post_type == 'picture' ? true : false
    @channel = @post.primary_channel
    @title = @post.title
    @description = @post.og_description
    build_og_tags(@post.og_title, @post.og_type, post_pretty_url(@post), @post.og_description)

    add_page_entity('channel', @channel)
    add_page_entity('post', @post)
  end

  def show_redirect
    @post = Post.find_by_token(params[:id])
    if @post.primary_channel
      redirect_to post_via_channel_url(@post.primary_channel, @post, :subdomain => @post.user.username), :status => :moved_permanently
    else
      redirect_to post_via_channel_url(0, @post, :subdomain => @post.user.username), :status => :moved_permanently
    end
  end

  def edit
    @post = Post.find_by_token(params[:id])
    authorize! :update, @post
    @body_class = "#{@post.post_type} #{@post.post_subtype} #{@post.style}"
    @fullscreen = @post.post_type == 'picture' ? true : false
    @editing = true
    add_page_entity('post', @post)
  end

  def destroy
    @post = Post.find_by_token(params[:id])
    authorize! :destroy, @post
    @post.destroy
    respond_to do |format|
      format.html { redirect_to user_url(:subdomain => current_user.username) }
      format.js
    end
  end

  def add_inline_photo
    @post = Post.find_by_token(params[:id])
    authorize! :update, @post
    photo = Cloudinary::Uploader.upload(params[:post][:photo], {:tags => ["post-#{@post.id}"], :format => 'jpg', :transformation => {:crop => :limit, :width => 1400, :height => 1400, :quality => 80}})
    url = Cloudinary::Utils.cloudinary_url("v#{photo['version']}/#{photo['public_id']}.jpg", {:crop => :limit, :width => 700})
    render :text => "{\"url\" : \"#{url}\", \"photo\" : \"v#{photo['version']}/#{photo['public_id']}.jpg\", \"id\" : \"#{photo['public_id']}\"}", :content_type => "text/plain"
  end

  def update_photo
    @post = Post.find_by_token(params[:id])
    authorize! :update, @post
    @post.photo = params[:post][:photo]
    @post.save
    @post.update_photo_attributes
    @post.save

    render :text => "{\"url\" : \"#{@post.photo_url}\"", :content_type => "text/plain"
  end

  def remove_photo
    @post = Post.find_by_token(params[:id])
    authorize! :update, @post
    @post.remove_photo!
    @post.update_photo_attributes
    @post.save
  end

  def update_audio
    @post = Post.find_by_token(params[:id])
    authorize! :update, @post
    @post.audio = params[:post][:audio]
    @post.save

    render :json => {:url => @post.audio_url, :name => @post.audio_name}
  end

  def remove_audio
    @post = Post.find_by_token(params[:id])
    authorize! :update, @post
    @post.remove_audio!
    @post.save
    render :json => {:status => 'success'}
  end

  def create_vote
    @post = Post.find_by_token(params[:id])

    # can't vote on your own posts
    if current_user && @post.user_id == current_user.id
      render :json => {:status => 'error'}, status: :unprocessable_entity
    else
      PostVote.add(@post.id, request.remote_ip, current_user ? current_user.id : nil)
      current_user.touch if current_user
      if current_user && current_user.email_recommended
        UserMailer.recommended(@post.id, current_user.id).deliver
      end
      render :json => {:status => 'success', :votes_count => @post.votes_count + 1}, status: 200
    end
  end

  def destroy_vote
    @post = Post.find_by_token(params[:id])

    stat = PostVote.retrieve(@post.id, request.remote_ip, current_user ? current_user.id : nil)
    if stat
      stat.destroy
      current_user.touch if current_user
      render :json => {:status => 'success', :votes_count => @post.votes_count - 1}, status: 200
    else
      render :json => {:status => 'error'}, status: :unprocessable_entity
    end
  end

  def create_read
    @post = Post.find_by_token(params[:id])
    user_id = current_user ? current_user.id : nil

    if @post.user_id == user_id || @post.status != 'active'
      render :json => {:status => 'success'}, status: 200
    else
      Stat.create_from_page_analytics('Post Read', current_user, [@post], request.referer, request.remote_ip)
      render :json => {:status => 'success'}, status: 200
    end
  end

  def add_channel
    @post = Post.find_by_token(params[:id])
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
    @post = Post.find_by_token(params[:id])
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
end