class Markdown

  def initialize(text)
    @text = text
    @processor = Kramdown::Document.new(@text)
  end

  def to_html
    @processor.to_html
  end

  def to_markdown
    @processor.to_markdown
  end

  def to_kramdown
    @processor.to_kramdown
  end

end