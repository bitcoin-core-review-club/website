# bitcoin-core-review-club

Simple Jekyll site for hosting the Bitcoin Core PR Review club at https://bitcoincore.reviews/.

## Development

You'll need [Ruby & Jekyll](https://jekyllrb.com/docs/installation/) to run the site locally. Once they're setup:

* Clone the repository and go into the directory
* Run `bundle install`
* Run `make preview`
* Go to http://localhost:4000

## Making a new post

See the [CONTRIBUTING.md](CONTRIBUTING.md) doc for how to create a post for an upcoming meeting.

## Changing Site Data

All site configurations are either contained in `_config.yml` or `_data/settings.yml`. Some data is duplicated between the two due to the way Jekyll injects variables, so be sure to update both.


## Attributions

Thanks to [LeNPaul](https://github.com/LeNPaul/jekyll-starter-kit) for the Jekyll starter kit this was forked from and to Will O'Beirne for pointing me in that direction.
