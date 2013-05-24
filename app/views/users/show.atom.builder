atom_feed :language => 'en-US' do |feed|
  feed.title "#{@user.username}'s Posts on Joint Ink"
  feed.subtitle @user.bio
  feed.updated @posts.maximum(:updated_at)

  @posts.scoped.each do |post|
    feed.entry(post) do |entry|
      entry.url post_pretty_url(post)
      entry.title post.title
      entry.content == markdown(post.content)
      entry.updated(post.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
      entry.published(post.published_at.strftime("%Y-%m-%dT%H:%M:%SZ"))

      entry.author do |author|
        author.name @user.username
      end
    end
  end
end