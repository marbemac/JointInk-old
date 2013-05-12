require "net/http"

class TestingController < ApplicationController

  def test

    #authorize! :manage, :all

    post = Post.find(16)
    width = post.photo.image_width
    foo = 'bar'
  end

end