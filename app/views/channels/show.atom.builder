atom_feed :language => 'en-US' do |feed|
  feed.title "\"#{@channel.name}\" Channel on Joint Ink"
  feed.subtitle @channel.description
  feed.updated @posts.maximum(:updated_at)

  @posts.scoped.each do |post|
    feed.entry(post) do |entry|
      entry.link post_pretty_url(post)
      entry.title post.title

      entry.content :type => 'html' do
        if post.photo.present?
          entry << (image_tag(post.photo_url) + markdown(post.content)).html_safe
        else
          entry << markdown(post.content).html_safe
        end
      end

      entry.published(post.published_at)

      entry.author do |author|
        author.name post.user.username
      end
    end
  end
end