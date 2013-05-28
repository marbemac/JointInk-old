class EmailsController < ApplicationController

  def post
    user = User.where(:email => params['sender']).first
    if user
      title = params['subject']

      if params['stripped-html'] && !params['stripped-html'].blank?
        html = params['stripped-html'].gsub(params['stripped-signature'], '') # remove the signature if we can
        content = ReverseMarkdown.parse content # if they formatted html this will turn that into markdown
      else
        content = params['stripped-text']
      end

      post = user.posts.new(:title => title, :content => content)
      post.status = params['status']
      post.save

      # process all attachments:
      #count = params['attachment-count'].to_i
      #count.times do |i|
      #  stream = params["attachment-#{i+1}"]
      #  filename = stream.original_filename
      #  data = stream.read()
      #end
    end

    render :text => "OK"
  end

end