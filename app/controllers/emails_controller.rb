class EmailsController < ApplicationController

  def post
    # process various message parameters:

    user = User.find(1)
    post = user.posts.create(:title => 'Email Debug', :text => params.to_s)
    post.save

    #user_email  = params['sender']
    #title = params['subject']
    #
    ## get the "stripped" body of the message, i.e. without
    ## the quoted part
    #actual_body = params["stripped-text"]
    #
    ## process all attachments:
    #count = params['attachment-count'].to_i
    #count.times do |i|
    #  stream = params["attachment-#{i+1}"]
    #  filename = stream.original_filename
    #  data = stream.read()
    #end

    render :text => "OK"
  end

end