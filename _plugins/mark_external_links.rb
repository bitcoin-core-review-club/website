# This file is based on code from https://github.com/riboseinc/jekyll-external-links

require 'nokogiri'
require 'uri'

# Given hostname and content, updates any found <a> elements as follows:
#
# - Adds `rel` attribute
# - Adds css class for external link icon
#
# Only processes external links where `href` starts with "http"
# and target host does not start with given site hostname.
def process_content(site_hostname, content, marker_css, link_selector)
  content = Nokogiri::HTML(content)
  content.css(link_selector).each do |a|
    next unless a.get_attribute('href') =~ /\Ahttp/i
    next if a.get_attribute('href') =~ /\Ahttp(s)?:\/\/#{site_hostname}\//i
    next if a.inner_html.include? "icon-ext"
    next if a.inner_html.include? "fa" # another icon is part of the link, e.g fa-github
    next if a.inner_html.include? a.get_attribute('href') # plain links
    a.set_attribute('rel', 'external')
    a.set_attribute('class', marker_css)
  end
  return content.to_s
end

def mark_links_in_page_or_document(page_or_document)
  site_hostname = URI(page_or_document.site.config['url']).host

  # The link is marked as external by:
  # (1) setting the rel attribute to external and
  # (2) appending specified marker css class.
  marker_css = "icon-ext"

  # Determines which links to mark. E.g., usually we don’t want to mark navigational links.
  link_selector = 'a:not(.internal-link)'

  # Do not process assets or other non-HTML files
  unless (page_or_document.respond_to?(:asset_file?) and
      page_or_document.asset_file?) or
      page_or_document.output_ext != ".html"
    page_or_document.output = process_content(
      site_hostname,
      page_or_document.output,
      marker_css,
      link_selector)
  end
end

Jekyll::Hooks.register :documents, :post_render do |doc|
  mark_links_in_page_or_document(doc)
end

Jekyll::Hooks.register :pages, :post_render do |page|
  mark_links_in_page_or_document(page)
end
