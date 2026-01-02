build-docker-image:
	docker image build -t vitepress-dev:latest .

dev-site: build-docker-image
	docker run -it --rm -p 5173:5173 -v .:/app -v /app/node_modules vitepress-dev:latest /bin/bash

.PHONY: build-docker-image dev-site
