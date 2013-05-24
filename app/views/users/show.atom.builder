atom_feed :language => 'en-US' do |feed|
  feed.title "#{@user.username}'s Posts on Joint Ink".html_safe
  feed.subtitle @user.bio
  feed.updated @posts.maximum(:updated_at)

  @posts.scoped.each do |post|
    feed.entry post, published: post.published_at do |entry|
      entry.title post.title

      entry.content :type => 'html' do
        if post.photo.present?
          entry << "<![CDATA[ #{(image_tag(post_photo_path(post, :width => 1000, :crop => :limit)) + markdown(post.content)).html_safe} ]]>"
        else
          entry << "<![CDATA[ #{markdown(post.content).html_safe} ]]>"
        end
      end

      entry.author do |author|
        author.name @user.username
      end
    end
  end
end