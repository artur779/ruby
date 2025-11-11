require "katex_prerender/version"

module KatexPrerender
  def self.render(math_expression)
    "<span class='math'>#{math_expression}</span>"
  end
end
