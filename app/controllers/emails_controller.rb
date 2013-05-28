class EmailsController < ApplicationController

  def post
    user = User.where(:email => params['sender']).first
    if user
      title = params['subject']

      if params['stripped-html'] && !params['stripped-html'].blank?
        html = params['stripped-html'].gsub(params['stripped-signature'], '') # remove the signature if we can
        content = ReverseMarkdown.parse(html) # if they formatted html this will turn that into markdown
      else
        content = params['stripped-text']
      end

      post = user.posts.new(:title => title, :content => content)
      post.emailed_from = params['sender']
      post.status = params['status']

      saved = post.save
      if saved # woo saved successfully!
        if post.status == 'published'
          UserMailer.published_by_email_confirmation(post.id).deliver
          # TODO: send a published event to segment.io like we do in the normal post update action
        end
      else # whoops, change it to draft and resave
        post.status = 'draft'
        post.save
      end

      post.update_photo_attributes
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