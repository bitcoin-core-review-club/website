# frozen_string_literal: true
# This file is based on code from https://github.com/maximevaillancourt/digital-garden-jekyll-template
# Generators run after Jekyll has made an inventory of the existing content, and before the site is generated.
class BidirectionalLinksGenerator < Jekyll::Generator
    def generate(site)
  
      all_notes = site.collections['topics'].docs
      all_posts = site.posts.docs
  
      all_pages = all_notes + all_posts
      pages_with_link_syntax = all_pages.select { |page| page.content.match(/\[\[.*?\]\]/) }
  
      # Convert all Wiki/Roam-style double-bracket link syntax to plain HTML
      # anchor tag elements (<a>) with "internal-link" CSS class
      pages_with_link_syntax.each do |current_page|
        all_pages.each do |page_potentially_linked_to|
          page_title_regexp_pattern = Regexp.escape(
            File.basename(
              page_potentially_linked_to.basename,
              File.extname(page_potentially_linked_to.basename)
            )
          ).gsub('\_', '[ _]').gsub('\-', '[ -]').capitalize
  
          title_from_data = title_from_data_escaped = page_potentially_linked_to.data['title']
          if title_from_data
            title_from_data_escaped = Regexp.escape(title_from_data)
          end
          pr_from_data = page_potentially_linked_to.data['pr'].to_s
          is_code = page_potentially_linked_to.data['code']

          new_href = "#{site.baseurl}#{page_potentially_linked_to.url}"
          title_anchor_tag = internal(new_href, title_from_data, is_code)
          pr_anchor_tag = internal(new_href,"##{pr_from_data} #{title_from_data}")

          # This block is used as replacement logic when an extra github link
          # is supported next to the double-bracket link syntax
          # e.g [[topic]](github-link-with-src-at-time-of-writing)
          anchor_tag = proc {
            title = "#$1"
            if is_code
              title = "<code>#{title}</code>"
            end
            anchor_tag = "<a class='internal-link' href='#{new_href}'>#{title}</a>"
            github_anchor_tag = "<a href='#$2'><i class='fa fa-github'></i></a>"
            # when exists, render github link as a github icon anchor 
            "#{anchor_tag}#{$2 ? github_anchor_tag : ''}"
          }

          optional_github_link = %r{(?:\(([^)]+)\))?}
          # Replace double-bracketed links that use the format "PR#pr_number" with pr_number & title 
          #[[PR#27050]] => [#27050 Don't download witnesses for assumed-valid blocks when running in prune mode](/27050) 
          current_page.content.gsub!(
            /\[\[PR##{pr_from_data}\]\]/i,
            pr_anchor_tag
          )

          # Replace double-bracketed links that use topic's title/filename with the given label
          # with title: [[Branch and Bound (BnB)|this is a link to bnb]] => [this is a link to bnb](/topics/bnb)
          # with filename: [[bnb|this is a link to bnb]] => [this is a link to bnb](/topics/bnb)
          current_page.content.gsub!(
            /\[\[(?:#{page_title_regexp_pattern}|#{title_from_data_escaped})\|(.+?)(?=\])\]\]#{optional_github_link}/i,
            &anchor_tag
          )

          # Replace double-bracketed links that use topic's title
          # [[coin selection]] => [coin selection](/topics/coin-selection)
          # [[Coin selection]] => [Coin selection](/topics/coin-selection)
          current_page.content.gsub!(
            /\[\[(#{title_from_data_escaped})\]\]#{optional_github_link}/i,
            &anchor_tag
          )
          # Replace double-bracketed links that use topic's filename with topic's title
          # [[bnb]] => [Branch and Bound (BnB)](/topics/bnb)
          current_page.content.gsub!(
            /\[\[(#{page_title_regexp_pattern})\]\]/i,
            title_anchor_tag
          )
        end
  
        # At this point, all remaining double-bracket-wrapped words are
        # pointing to non-existing pages, so let's turn them into disabled
        # links by greying them out and changing the cursor
        #
        # @TODO: disabled for now as this creates problem with actual usage of [[]], e.g `[[nodiscard]]`
        # current_page.content = current_page.content.gsub(
        #   /\[\[([^\]]+)\]\]/i, # match on the remaining double-bracket links
        #   <<~HTML.delete("\n") # replace with this HTML (\\1 is what was inside the brackets)
        #     <span title='There is no page that matches this link.' class='invalid-link'>
        #       <span class='invalid-link-brackets'>[[</span>
        #       \\1
        #       <span class='invalid-link-brackets'>]]</span></span>
        #   HTML
        # )
      end
  
      # Identify page backlinks and add them to each page
      all_pages.each do |current_page|
        # Nodes: Jekyll
        # Create a hash to store documents and their surrounding snippets that link to the current page
        pages_linking_to_current_page = []
        current_page_href = "href='#{current_page.url}'"

        # Iterate over pages that have double-bracket to find links to the current page
        pages_with_link_syntax.each do |page_potentially_linking_to|
          # Check if the current page is linked to in the potential linking page's content
          if page_potentially_linking_to.content.include?(current_page_href)
            # Find the paragraph snippets that link to the current page
            paragraph_snippets = get_matching_text_blocks(page_potentially_linking_to.content, current_page_href)
            # Add the document and its snippets to the hash
            pages_linking_to_current_page << {"doc" => page_potentially_linking_to, "snippets" => paragraph_snippets}
          end
        end
  
        # Edges: Jekyll
        current_page.data['backlinks'] = pages_linking_to_current_page

      end
    end
  
    def page_id_from_page(page)
      page.data['title'].bytes.join
    end

    def internal(href, title, is_code=false)
      if is_code
        # encapsulate title with code
        title = "<code>#{title}</code>"
      end
      "<a class='internal-link' href='#{href}'>#{title}</a>"
    end

    def get_matching_text_blocks(text, url)
      # This is called only when we know that a match exists
      # The logic here assumes that:
      # - paragraphs have headers
      # - each block of text (paragraph) is seperated by an empty line 

      # Split the text into paragraphs
      paragraphs = text.split(/\n\n+/)
      # Find all the headers in the text
      headers = text.scan(/^#+\s+(.*)$/).flatten

      # Create an array of hashes containing the paragraph text and the associated header
      current_header = 0
      matching_paragraphs = []

      # Iterate over all paragraphs to find those that match the given url
      paragraphs.each do |p|
        # If the current paragraph contains the URL, add it to the matching paragraphs
        if p.include?(url)
          matching_paragraphs << {"paragraph"=> p, "header"=> headers[current_header]}
        end

        # update to the next header when parse through it
        if p.sub(/^#+\s*/, "") == headers[(current_header + 1) % headers.length()]
          current_header += 1
          # There is no need to parse after the Meeting Log section, 
          # there are no double-bracket links there
          if headers[current_header] == "Meeting Log"
            break
          end
        end
      end
    
      # Return the matching paragraphs
      matching_paragraphs
    end
    
    
  end
  