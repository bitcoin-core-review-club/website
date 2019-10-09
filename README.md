# bitcoin-core-review-club

Simple Jekyll site for hosting the Bitcoin Core PR Review club at https://bitcoincore.reviews/.

## Development

You'll need [Ruby & Jekyll](https://jekyllrb.com/docs/installation/) to run the site locally. Once they're setup:

* Clone the repository and go into the directory
* Run `bundle install`
* Run `make preview`
* Go to http://localhost:4000

## Making a Post

To make a new post, run the following Ruby make command from root or the
`_posts` directory:

```shell
rake posts:new -- --pr NUMBER --host USERNAME --date YYYY-MM-DD
```

or with short arguments:

```shell
rake posts:new -- -p NUMBER -h USERNAME -d YYYY-MM-DD
```

For more details/help, run:

```shell
rake posts:new -- --help
```

The `pr` and `host` arguments are required. The `date` argument is optional;
if none is passed the meeting date will be set by default to next Wednesday.

This command will create a new markdown file for the post, with metadata and
initial Notes and Questions headers.

## Changing Site Data

All site configurations are either contained in `_config.yml` or `_data/settings.yml`. Some data is duplicated between the two due to the way Jekyll injects variables, so be sure to update both.


## Attributions

Thanks to [LeNPaul](https://github.com/LeNPaul/jekyll-starter-kit) for the Jekyll starter kit this was forked from and to Will O'Beirne for pointing me in that direction.
