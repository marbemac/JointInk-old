class PostsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]

  def new
    @channel = Channel.find(params[:id])
    authorize! :post, @channel

    @post = current_user.posts.create(:status => 'idea', :post_type => params[:type], :post_subtype => params[:subtype])
    @post.add_channel current_user, @channel
    authorize! :create, @post

    redirect_to edit_post_path(@post)
  end

  def update
    @post = Post.find(params[:id])
    authorize! :update, @post

    respond_to do |format|
      if @post.update_attributes(params[:post])
        @post.update_photo_attributes
        @post.save
        format.html { redirect_to post_via_channel_path(@post.primary_channel, @post)}
        format.js { render :json => {:post => @post, :url => post_path(@post)} }
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
    @description = @post.content
    build_og_tags(@post.og_title, @post.og_type, @post.permalink, @post.og_description)
  end

  def show_redirect
    @post = Post.find(params[:id])
    redirect_to post_via_channel_path(@post.primary_channel, @post)
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
      format.html { redirect_to user_path(current_user) }
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

  def create_vote
    @post = Post.find(params[:id])

    # can't vote on your own posts
    if @post.user_id == current_user.id
      render :json => {:status => 'error'}, status: :unprocessable_entity
    else
      PostStat.add(@post.id, request.remote_ip, 'vote', request.referer, current_user.id)
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
end