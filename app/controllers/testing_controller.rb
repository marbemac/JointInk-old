require "net/http"

class TestingController < ApplicationController

  def test

    #authorize! :manage, :all

    post = Post.find(16)
    width = post.photo.image_width
    foo = 'bar'
  end

  def new_outreach
    authorize! :manage, :all

    if params[:url]
      unless Outreach.where(:url => params[:url]).first
        agent = Mechanize.new
        agent.get("http://#{URI.parse(params[:url]).host}/ask")
        if agent.page.code == "200"
          agent.get(params[:url])
          @timeago_links = agent.page.parser.css('.timeago a, a.timeago, a.timestamp')
          @note_links = agent.page.links_with(:text => /notes/)
          #@timeagos = @timeagos | agent.page.links_with(:text => "Notes")
        end
      end
    end

  end

  def create_outreach
    authorize! :manage, :all
  end

end