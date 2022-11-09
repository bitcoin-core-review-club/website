# frozen_string_literal: true

require 'uri'

module Jekyll
  class IRCBlock < Liquid::Block
    # Convert IRC meeting logs from plain text to HTML with functional links
    # and log lines by enclosing them in {% irc %} and {% endirc %} tags.

    # URI schemes to accept for extraction.
    URI_SCHEMES = %w(http https).freeze

    # Trailing chars (all punctuation except "/") to remove from URIs.
    TRAILING = /[^\/[:^punct:]]+$/

    # Regex to select lines starting with "HH:MM " time.
    HH_MM = /^([0-1][0-9]|[2][0-3]):[0-5][0-9] .*/

    # Regex to select IRC <nick>.
    IRC_NICK = /^(?:\s*)(<.+?>)/

    # Regex to select "<" and ">" chars.
    LT_GT = /[<>]/

    # Maximum digits to display for log lines.
    LINE_DIGITS = 3

    # Length of timestamp string being used.
    TIME_SIZE = 'HH:MM'.size
    TIME_SIZE_PLUS_1 = TIME_SIZE + 1 # Micro-perf optimization

    NON_BREAKING_SPACE = '&nbsp;'

    COLORS = %w(brown goldenrod cadetblue chocolate cornflowerblue coral crimson
      forestgreen darkblue firebrick blue green grey hotpink indianred indigo
      blueviolet maroon mediumblue mediumpurple mediumseagreen navy fuchsia
      olive orchid purple red seagreen sienna orange slateblue peru salmon teal
      magenta steelblue rebeccapurple tomato violet darkcyan).freeze

    NUM_COLORS = COLORS.size.freeze

    def initialize(tag_name, text, tokens)
      super
    end

    def render(context)
      output = super

      # Reset color data for each post. Seed the index with part of the content.
      colors, color_index = {}, (output[-256..-250] || '').bytes.sum

      # Loop through each line of the meeting logs.
      output.gsub!(HH_MM).with_index(1) do |line, index|

        # Separate the log line into useful parts.
        lineno  = "#{NON_BREAKING_SPACE * (LINE_DIGITS - index.to_s.size)}#{index}"
        time    = line[0..TIME_SIZE]
        name    = IRC_NICK.match(line[TIME_SIZE_PLUS_1..-1]).to_s
        nick    = name.gsub(LT_GT, '').strip
        color   = colors[nick] || (color_index = (color_index + 1) % NUM_COLORS ;
                                   colors[nick] = COLORS[color_index])
        nick    = "&lt;#{nick}&gt;" unless nick == ''
        message = CGI.escapeHTML(line[TIME_SIZE_PLUS_1 + name.size..-1])

        # Extract URIs from the message and convert them to HTML links.
        URI.extract(message, schemes = URI_SCHEMES).each do |uri|
          link = uri.sub(TRAILING, '') # Strip unwanted trailing punctuation
          message.sub!(link, "<a href='#{link}' target='blank'>#{link}</a>")
        end

        # Return the log line as HTML markup.
        "<table class='log-line' id='l-#{index}'>" \
          "<tr class='log-row'>" \
            "<td class='log-lineno'><a href='#l-#{index}'>#{lineno}</a></td>" \
            "<td class='log-time'>#{time}</td>" \
            "<td>" \
              "<span class='log-nick' style='color:#{color}'>#{nick}</span>" \
              "<span class='log-msg'>#{message}</span>" \
            "</td>" \
          "</tr>" \
        "</table>"
      end

      output
    end
  end
end

Liquid::Template.register_tag('irc', Jekyll::IRCBlock)
