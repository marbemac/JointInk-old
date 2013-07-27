class Markdown
  include_class Java::OrgPegdown::PegDownProcessor

  def initialize(text)
    @text = text
    @processor = PegDownProcessor.new
  end

  def to_html
    @processor.markdownToHtml(@text)
  end
end