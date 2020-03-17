# frozen_string_literal: true

# Convert plain text log into HTML markup with line number links.
Jekyll::Hooks.register :documents, :pre_render do |post|
  # Regex to select lines that begin with HH:MM time.
  # post.content.partition("Meeting Log").last.gsub!(/^([0-1][0-9]|[2][0-3]):[0-5][0-9] .*/).with_index(1) do |line, index|
  post.content.gsub!(/^([0-1][0-9]|[2][0-3]):[0-5][0-9] .*/).with_index(1) do |line, index|
    # Separate the log line into individual parts.
    lineno  = "#{'&nbsp;' * (4 - index.to_s.length)}#{index}"
    time    = line[0..5]
    nick    = /<.+?>/.match(line).to_s.gsub(/[<>]/, '').strip
    message = CGI.escapeHTML(line[6..-1].sub(/<.+?>/, ''))
    # Return the log line in HTML markup version.
    "<table class=\"log-line\" id=\"l-#{index}\"><tr class=\"log-row\">" \
      "<td class=\"log-lineno\"><a href=\"#l-#{index}\">#{lineno}</a></td>" \
      "<td class=\"log-time\">#{time}</td>" \
      "<td><span class=\"log-nick\">&lt;#{nick}&gt;</span>" \
      "<span class=\"log-msg\">#{message}</span></td></tr></table>"
  end
end
