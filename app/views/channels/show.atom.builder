atom_feed :language => 'en-US' do |feed|
  feed.title "\"#{@channel.name}\" Channel on Joint Ink"
  feed.subtitle @channel.description
  feed.updated @posts.maximum(:updated_at)

  @posts.scoped.each do |post|
    feed.entry(post) do |entry|
      entry.link post_pretty_url(post)
      entry.title post.title

      if post.photo.present?
        entry.content == image_tag(post.photo_url).html_safe + markdown(post.content)
      else
        entry.content == markdown(post.content)
      end

      entry.updated(post.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
      entry.published(post.published_at.strftime("%Y-%m-%dT%H:%M:%SZ"))

      entry.author do |author|
        author.name post.user.username
      end
    end
  end
end