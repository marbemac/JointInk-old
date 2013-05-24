xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{@user.username}'s Posts on Joint Ink"
    xml.description @user.bio
    xml.link user_url(:subdomain => @user.username)

    for post in @posts
      xml.item do
        xml.title post.title

        #if post.photo.present?
        #  xml.description << (image_tag(post.photo_url) + markdown(post.content)).html_safe
        #else
        xml.description 'test'
        #end

        xml.pubDate post.published_at.to_s(:rfc822)
        xml.link post_pretty_url(post)
        xml.guid post.permalink
      end
    end
  end
end