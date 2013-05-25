module ActionView::Base
  def json_escape(s)
    result = s.to_s.gsub('/', '\/')
    s.html_safe? ? result.html_safe : result
  end

  alias jsone json_escape
end