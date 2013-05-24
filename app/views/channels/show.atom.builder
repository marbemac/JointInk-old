atom_feed :language => 'en-US' do |feed|
  feed.title "\"#{@channel.name}\" Channel on Joint Ink"
  feed.subtitle @channel.description
  feed.updated @posts.maximum(:updated_at)

  @posts.scoped.each do |post|
    feed.entry post, published: post.published_at do |entry|
      entry.title post.title

      entry.content :type => 'html' do
        if post.photo.present?
          entry << "<![CDATA[ #{(image_tag(post.photo_url) + markdown(post.content)).html_safe} ]]>"
        else
          entry << "<![CDATA[ #{markdown(post.content).html_safe} ]]>"
        end
      end

      entry.author do |author|
        author.name post.user.username
      end
    end
  end
end