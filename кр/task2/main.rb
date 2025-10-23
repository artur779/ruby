class ReportFormatter
  def format(title, text)
    raise NotImplementedError, 'Цей метод має бути реалізований у підкласі'
  end
end

class TextFormatter < ReportFormatter
  def format(title, text)
    "***** #{title} *****\n\n#{text.join("\n")}\n"
  end
end

class MarkdownFormatter < ReportFormatter
  def format(title, text)
    "# #{title}\n\n" + text.map { |line| "- #{line}" }.join("\n")
  end
end

class HtmlFormatter < ReportFormatter
  def format(title, text)
    <<~HTML
      <html>
        <head><title>#{title}</title></head>
        <body>
          <h1>#{title}</h1>
          <ul>
            #{text.map { |line| "<li>#{line}</li>" }.join("\n")}
          </ul>
        </body>
      </html>
    HTML
  end
end

class Report
  attr_accessor :title, :text, :formatter

  def initialize(title, text, formatter)
    @title = title
    @text = text
    @formatter = formatter
  end

  def output
    @formatter.format(@title, @text)
  end
end

report = Report.new(
  "Звіт про продажі",
  ["Продажі за січень: $10000", "Продажі за лютий: $12000"],
  TextFormatter.new
)

puts "=== Text формат ==="
puts report.output

report.formatter = MarkdownFormatter.new
puts "\n=== Markdown формат ==="
puts report.output

report.formatter = HtmlFormatter.new
puts "\n=== HTML формат ==="
puts report.output


