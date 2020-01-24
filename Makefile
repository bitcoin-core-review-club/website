preview_serve_cmd = jekyll serve --future --drafts --unpublished --incremental
docker_run_cmd = docker run --rm --volume="$(PWD):/srv/jekyll" -it
docker_img = jekyll/jekyll:3.8

.PHONY: all
all: build

.PHONY: preview
preview:
	bundle exec jekyll clean
	bundle exec $(preview_serve_cmd)

.PHONY: build
build:
	bundle exec jekyll clean
	bundle exec jekyll build --future --drafts --unpublished

.PHONY: docker-sh
docker-sh:
	$(docker_run_cmd) $(docker_img) /bin/bash

.PHONY: docker-serve
docker-serve:
	$(docker_run_cmd) -p 4000:4000 $(docker_img) $(preview_serve_cmd)
