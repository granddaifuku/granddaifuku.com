all: build-site

build-docker-image:
	docker image build -t astro-site-builder:latest .

build-site: build-docker-image
	docker run --rm -v .:/app -v /app/node_modules astro-site-builder:latest yarn run build

enter: build-docker-image
	docker run -it --rm -v .:/app -v /app/node_modules astro-site-builder:latest /bin/bash

.PHONY: build-docker-image build-site enter
