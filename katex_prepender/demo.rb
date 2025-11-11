$LOAD_PATH.unshift(File.expand_path("lib", __dir__))
require_relative "lib/katex_prerender"

puts "Demo of KatexPrerender:"
puts KatexPrerender.render("a^2 + b^2 = c^2")
