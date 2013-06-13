module PostHelper

  def post_photo_path(post, options)
    update_image_options(options)
    if post.photo.present?
      cl_image_path(post.photo_image, options)
    else
      nil
    end
  end

  def post_pretty_url(post)
    if post.primary_channel
      user_pretty_url(post.user) + post_via_channel_path(post.primary_channel, post)
    else
      user_pretty_url(post.user) + post_path(post)
    end
  end

  class RenderDifferentHeaderCode < Redcarpet::Render::HTML
    def header(text, header_level)
      header = [header_level+2, 6].min
      "<h#{header}>#{text}</h#{header}>"
    end
  end

  def markdown(text, render_options={})
    return '' unless text

    if render_options[:no_links]
      text.gsub! /\[([^\]]+)\]\(([^)]+)\)/, '\1'
    end

    render_options = render_options.merge(hard_wrap: false, filter_html: true, prettify: true, no_styles: true, :link_attributes => {:rel => 'nofollow'})

    renderer = RenderDifferentHeaderCode.new(render_options)
    options = {
        autolink: true,
        no_intra_emphasis: true,
        fenced_code_blocks: true,
        lax_html_blocks: true,
        strikethrough: true,
        superscript: true
    }
    Redcarpet::Markdown.new(renderer, options).render(text).html_safe
  end

end