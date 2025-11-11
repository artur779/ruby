require "katex_prerender"

RSpec.describe KatexPrerender do
  it "has a version number" do
    expect(KatexPrerender::VERSION).not_to be nil
  end

  it "renders a math expression" do
    result = KatexPrerender.render("E=mc^2")
    expect(result).to eq("<span class='math'>E=mc^2</span>")
  end
end
