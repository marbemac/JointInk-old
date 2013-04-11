module PostHelper

  def post_photo_path(post, options)
    update_image_options(options)
    if post.photo.present?
      cl_image_path(post.photo_image, options)
    else
      nil
    end
  end

  def markdown(text)
    return '<p>Write content here..</p>'.html_safe unless text
    renderer = Redcarpet::Render::HTML.new(hard_wrap: false, filter_html: true, prettify: true, no_styles: true, :link_attributes => {:rel => 'nofollow'})
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
