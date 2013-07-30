class EmailsController < ApplicationController

  def post

    skip = false
    # skip emails to the team
    if ['tech@jointink.com','team@jointink.com','hello@jointink.com','founders@jointink.com','contact@jointink.com'].any? { |word| params['recipient'].include?(word) }
      skip = true
    end

    unless skip

      user = User.where(:email => params['sender']).first
      anonymous = false
      new_user = false

      # create the new user
      unless user
        new_user = true
        anonymous = true
        user = User.new
        user.email = params['sender']
        user.generate_username_from_email
        password = SecureRandom.hex(8)
        user.password = password
        user.save
      end

      last_post = user.posts.order('created_at DESC').first

      # don't allow posts within 60 seconds
      unless last_post && Time.now.to_i - last_post.created_at.to_i < 60

        title = params['subject']

        duplicate = user.posts.where(:title => title).first

        unless duplicate
          if params['stripped-html'] && !params['stripped-html'].blank?
            html = params['stripped-html'].gsub(params['stripped-signature'], '') # remove the signature if we can
            content = Kramdown::Document.new(html).to_kramdown # if they formatted html this will turn that into markdown
          else
            content = params['stripped-text']
          end

          post = user.posts.new(:title => title, :content => content)
          post.emailed_from = params['sender']

          if params['recipient'].include? 'drafts@'
            post.status = 'draft'
          elsif params['recipient'].include? 'publish@'
            post.status = 'active'
          else
            post.status = params['status']
          end

          saved = post.save
          if saved # woo saved successfully!
            if post.status == 'active'
              UserMailer.published_by_email_confirmation(post.id).deliver
              # TODO: send a published event to segment.io like we do in the normal post update action
            end
          else # whoops, change it to draft and resave
            post.status = 'draft'
            post.save
          end

          post.spam_score = params['X-Mailgun-Sscore']
          post.update_photo_attributes
          post.anonymous = anonymous
          post.save

          # handle channels
          params['recipient'].split(',').each do |recipient|
            email = recipient.strip.split('@').first
            channel = Channel.where("LOWER(email) = ?", email.downcase).first
            if channel
              if user.can?(:post, channel)
                post.add_channel(user, channel)
              end
            end
          end
        end

        if new_user
          #UserMailer.new_anonymous_user(user.id).deliver
        end

      end

      # process all attachments:
      #data = ''
      #count = params['attachment-count'].to_i
      #count.times do |i|
      #  stream = params["attachment-#{i+1}"]
      #  data += "#{stream.content_type} - #{stream.original_filename} - #{stream.size}"
      #  #filename = stream.original_filename
      #  #data = stream.read()
      #end
    end

    render :text => "OK"
  end

end