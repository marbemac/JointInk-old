atom_feed do |feed|
  feed.title "#{@user.name}'s #{@channel ? @channel.name : ''} #{@page}"
  feed.updated @posts.maximum(:updated_at)

  @posts.scoped.each do |post|
    feed.entry(post) do |entry|
      entry.title post.title
      entry.content post.description ? post.description : 'No description.', :type => 'html'
      entry.author do |author|
        author.name post.source.name
      end
    end
  end
end