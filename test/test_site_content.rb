# frozen_string_literal: true

require_relative 'test_helper'
require 'curb'
require 'uri'

class TestSiteContent < Minitest::Test
  # Load content from site XML feed, either in production, or locally after
  # running `make preview`, and run tests on the content.
  #
  # To run only this test file: rake TEST=test/test_site_content

  # Uncomment the desired website url:
  # SITE = 'https://bitcoincore.reviews'
  SITE = 'localhost:4000'
  URI_SCHEMES = %w(http https).freeze
  HTTP_SUCCESS = 200
  HTTP_ERROR = 400
  # Regex to select all trailing punctuation except "/".
  TRAILING_PUNCTUATION = /[^\/[:^punct:]]+$/

  def setup
    http = Curl.get("#{SITE}/feed.xml")
    assert_equal HTTP_SUCCESS, http.response_code
    @body = http.body
  end

  def test_site_displays_no_empty_nicks
    # Check that no empty nicks are displayed, e.g. "<> * luke-jr wonders..."
    # To run only this test:
    # rake TEST=test/test_site_content TESTOPTS=--name=test_site_displays_no_empty_nicks
    #
    refute @body.include? "&amp;lt;&amp;gt;"
  end

  def test_all_links
    # Check the HTTP status of all URLs in the site-wide XML feed.
    # To run only this test:
    # rake TEST=test/test_site_content TESTOPTS=--name=test_all_links

    # Scrape potential links.
    urls = URI.extract(@body, schemes = URI_SCHEMES).uniq

    # Strip any trailing wierdness.
    urls.each_with_index do |url, index|
      str = url.sub(TRAILING_PUNCTUATION, '')
      parts = str.split('&')
      str = parts.first if parts.size > 1
      urls[index] = str
    end

    urls.uniq!
    total, errors = urls.count, 0

    # Test the links...
    puts "#{total} unique links found, now testing..."
    puts '  count  |  status   |  url'

    urls.each.with_index(1) do |url, index|
      count = "#{' ' * (total.to_s.size - index.to_s.size)}#{index}"
      status = Curl.get(url).response_code

      if status == HTTP_SUCCESS
        puts "#{count}/#{total}  |    #{status}    |  #{url}"
      else
        puts "#{count}/#{total}  |  **#{status}**  |  #{url}"
        errors += 1 if status >= HTTP_ERROR
      end
    end
    assert_equal 0, errors
  end
end
