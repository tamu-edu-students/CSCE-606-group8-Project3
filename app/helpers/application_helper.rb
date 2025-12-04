module ApplicationHelper
  require 'redcarpet'

  def render_markdown(text)
    return "" if text.blank?

    renderer = Redcarpet::Render::HTML.new(
      filter_html: true,     # 过滤用户输入的 HTML 标签，防止 XSS
      hard_wrap: true,       # 将换行符转换为 <br>
      link_attributes: { rel: 'nofollow', target: "_blank" }
    )

    markdown = Redcarpet::Markdown.new(renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      no_intra_emphasis: true
    )

    markdown.render(text).html_safe
  end
end