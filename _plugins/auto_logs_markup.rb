# frozen_string_literal: true

require 'uri'

# URI schemes to accept for extraction.
URI_SCHEMES = %w(http https).freeze

# Trailing chars to remove from URIs.
TRAILING = /[[:punct:]]+$/

# Regex to select lines starting with "HH:MM " time.
HH_MM = /^([0-1][0-9]|[2][0-3]):[0-5][0-9] .*/

# Regex to select IRC <nick>.
IRC_NICK = /<.+?>/

# Regex to select "<" and ">" chars.
LT_GT = /[<>]/

# Maximum digits to display for log lines.
LINE_DIGITS = 3

# Length of timestamp string being used.
TIME_SIZE = 'HH:MM'.size
TIME_SIZE_PLUS_1 = TIME_SIZE + 1 # Micro-perf optimization

NON_BREAKING_SPACE = '&nbsp;'

# Convert logs from plain text to HTML with line number links.
#
Jekyll::Hooks.register :documents, :pre_render do |post|

  # Loop through each line of the meeting logs.
  post.content.gsub!(HH_MM).with_index(1) do |line, index|

    # Separate the log line into useful parts.
    lineno  = "#{NON_BREAKING_SPACE * (LINE_DIGITS - index.to_s.size)}#{index}"
    time    = line[0..TIME_SIZE]
    name    = IRC_NICK.match(line).to_s
    nick    = name.gsub(LT_GT, '').strip
    message = CGI.escapeHTML(line[TIME_SIZE_PLUS_1 + name.size..-1])

    # Extract URIs from the message and convert them to HTML links.
    URI.extract(message, schemes = URI_SCHEMES).each do |uri|
      message.sub!(uri, "<a href='#{uri.gsub!(TRAILING, '')}' target='blank'>#{uri}</a>")
    end

    # Return the log line as HTML markup.
    "<table class='log-line' id='l-#{index}'>" \
      "<tr class='log-row'>" \
        "<td class='log-lineno'><a href='#l-#{index}'>#{lineno}</a></td>" \
        "<td class='log-time'>#{time}</td>" \
        "<td>" \
          "<span class='log-nick'>&lt;#{nick}&gt;</span>" \
          "<span class='log-msg'>#{message}</span>" \
        "</td>" \
      "</tr>" \
    "</table>"
  end
end
