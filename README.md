# bitcoin-core-review-club

Simple Jekyll site for hosting information about upcoming Bitcoin Core PR Review club information.

## Development

You'll need [Ruby & Jekyll](https://jekyllrb.com/docs/installation/) to run the site locally. Once they're setup:

* Clone the repository and go into the directory
* Run `bundle install`
* Run `jekyll serve`
* Go to http://localhost:4000

## Making a Post

To make a new post, make a new file in `_posts/` with a title of `YYYY-MM-DD-title-goes-here`. At the top of the file you'll want to provide the following information:

```md
---
layout: post # Always post
title: "#<PR number> <PR title>"
---
```

After that, it's just simple markdown. The site will auto-generate the rest.

## Changing Site Data

All site configurations are either contained in `_config.yml` or `_data/settings.yml`. Some data is duplicated between the two due to the way Jekyll injects variables, so be sure to update both.


## Attributions

Thanks to [LeNPaul](https://github.com/LeNPaul/jekyll-starter-kit) for the Jekyll starter kit this was forked from and to Will O'Beirne for pointing me in that direction.
