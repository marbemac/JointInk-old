class StatsController < ApplicationController

  def create
    entities = []

    if params[:post_id]
      @post = Post.find(params[:post_id])
      entities << @post
    end

    if params[:channel_id]
      @channel = Channel.find(params[:channel_id])
      entities << @channel
    end

    if current_user && @post && (current_user.id == @post.user_id || @post.status != 'active')
      render :json => {:status => 'success'}, status: 200
    else
      Stat.create_from_page_analytics(params[:type], current_user, entities, (params[:referrer] && !params[:referrer].blank? ? params[:referrer] : nil), request.remote_ip)
      render :json => {:status => 'success'}, status: 200
    end
  end

end