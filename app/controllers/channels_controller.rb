class ChannelsController < ApplicationController
  before_filter :authenticate_user!, :only => [:new,:update,:edit]

  def new
    @channel = Channel.new
    authorize! :create, @channel
  end

  def edit
    @channel = Channel.find(params[:id])
    authorize! :update, @channel
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
      redirect_to channel_path(@channel), :status => :moved_permanently
    end

    @posts = @channel.posts.active
    @title = @channel.name
    @page_title = @channel.name
    @description = @channel.description
    build_og_tags(@channel.og_title, @channel.og_type, @channel.permalink, @channel.og_description)
  end

end
