# frozen_string_literal: true
# This file is based on code from https://github.com/bitcoinops/bitcoinops.github.io

# Automatically adds id tags (anchors) to list items

require 'digest/md5'

def generate_slug(text)
  # Remove double-quotes from titles before attempting to slugify
  text.gsub!('"', '')
  # Remove whitespace character from the end and use Liquid/Jekyll slugify filter
  slug_text = "{{ \"#{text.rstrip}\" | slugify: 'latin' }}"
  # use the digest library to create deterministic ids based on text
  id = Digest::MD5.hexdigest(slug_text)[0...7]
  slug = "\#b#{id}" # prefix with 'b', ids cannot start with a number
  slug
end

def generate_anchor_list_link(anchor_link, class_name='anchor-list-link')
  # custom clickable bullet linking to an anchor
  "<a href=\"#{anchor_link}\" class=\"#{class_name}\">●</a>"
end

def auto_anchor(content)
  # finds “bulleted” list items that start with hyphen (-) or asterisk (*)
  # adds anchor and clickable bullet
  content.gsub!(/^ *[\*-] .*?(?:\n\n|\z)/m) do |bulleted_paragraph|
    slug = generate_slug(bulleted_paragraph)
    bullet_character = bulleted_paragraph.match(/^ *([\*-])/)[1] # bullet can be '-' or '*'
    id_prefix = "#{bullet_character} {:#{slug} .anchor-list} #{generate_anchor_list_link(slug)}"
    bulleted_paragraph.sub!(/#{Regexp.quote(bullet_character)}/, id_prefix)
  end
  # finds “numbered” list items that start with number (1.)
  # adds anchor only
  content.gsub!(/^ *\d+\. .*?(?:\n\n|\z)/m) do |numbered_paragraph|
    slug = generate_slug(numbered_paragraph)
    id_prefix = "1. {:#{slug} .anchor-list .anchor-numbered}"
    numbered_paragraph.sub!(/\d+\./, id_prefix)
  end
end

## Run automatically on all documents
Jekyll::Hooks.register :documents, :pre_render do |post|
  ## Don't process documents if YAML headers say: "auto_id: false"
  unless post.data["auto_id"] == false
    auto_anchor(post.content)
  end
end

module TextFilter
  # This is a custom filter used in backlinks.html to 
  # add anchor links to each backlink snippet
  def link_to_anchor(text, url)
    slug = generate_slug(text)
    id_prefix = generate_anchor_list_link("#{url}#{slug}", "backlink-link")
    text.sub!(/(?:-|\*|\d+\.)/, id_prefix) # this targets both “bulleted” and “numbered” list items
    text
  end
end

Liquid::Template.register_filter(TextFilter)
