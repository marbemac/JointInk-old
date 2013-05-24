class ChannelsController < ApplicationController
  before_filter :authenticate_user!, :only => [:new,:update,:edit]

  def index
    @channels = Channel.active.with_posts.order("posts_count DESC")
  end

  def new
    @channel = Channel.new
    @fullscreen = true
    authorize! :create, @channel
  end

  def edit
    @channel = Channel.find(params[:id])
    @fullscreen = true
    authorize! :update, @channel
    add_page_entity('channel', @channel)
  end

  def create
    @channel = current_user.channels.build(params[:channel])
    authorize! :create, @channel

    respond_to do |format|
      if @channel.save
        format.html do
          redirect_to @channel, notice: 'Channel was successfully created.'
        end
      else
        format.html { render :action => "new" }
        format.json { render :json => {:errors => @channel.errors}, status: :unprocessable_entity }
      end
    end
  end

  def update
    @channel = Channel.find(params[:id])
    authorize! :update, @channel

    respond_to do |format|
      if @channel.update_attributes(params[:channel])
        @channel.touch_posts
        format.html { redirect_to channel_path(@channel), notice: 'Channel was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def show
    @channel = Channel.find(params[:id])
    authorize! :read, @channel

    if params[:id].is_a? Integer
      redirect_to channel_url(@channel, :subdomain => false), :status => :moved_permanently
    elsif request.subdomain && request.subdomain.present? && request.subdomain != 'www'
      redirect_to channel_url(@channel, :subdomain => false)
    end

    @posts = @channel.posts.active.order('votes_count DESC, created_at DESC')
    @title = @channel.name
    @page_title = @channel.name
    @description = @channel.description
    build_og_tags(@channel.og_title, @channel.og_type, @channel.permalink, @channel.og_description)
    add_page_entity('channel', @channel)

    respond_to do |format|
      format.html
      format.atom { render :layout => false }
      format.rss { redirect_to channel_feed_path(:format => :atom), :status => :moved_permanently }
    end
  end

  # invited members
  def members

  end

end
