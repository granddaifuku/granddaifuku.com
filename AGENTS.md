# AGENTS.md

This repository hosts `granddaifuku.com`, a personal website built with VitePress.

## Tech stack

- VitePress `2.0.0-alpha.15`
- Vue components inside the VitePress theme layer
- pnpm for package management
- Docker for the expected local development environment
- Netlify for deployment
- `oxfmt` for formatting

## Repository layout

- `.vitepress/config.mts`: main VitePress site configuration
- `.vitepress/site.ts`: shared site constants such as the canonical hostname
- `.vitepress/loader/posts.data.ts`: content loader for blog posts
- `.vitepress/theme/`: custom theme extensions, including the post share actions UI
- `posts/`: blog posts and related images
- `about/`: about page content
- `index.md`: homepage content

## Development workflow

The expected workflow is to run all project commands inside Docker.

### Start an interactive dev shell

```sh
make dev-site
```

This target builds the Docker image if needed, then starts a container with the repository mounted at `/app`.

Inside the container, run commands such as:

```sh
pnpm docs:dev --host
pnpm format:check
pnpm docs:build
```

`pnpm docs:dev --host` serves the site on port `5173`. The `make dev-site` command already publishes that port to the host.

### Build the Docker image only

```sh
make build-docker-image
```

### Run one-off commands without entering an interactive shell

```sh
docker run --rm -v "$PWD":/app -v /app/node_modules vitepress-dev:latest /bin/bash -lc 'pnpm format:check && pnpm docs:build'
```

That is useful for CI-like validation from the terminal assistant.

## Validation commands

Use the existing project scripts only:

```sh
pnpm format:check
pnpm docs:build
```

If formatting needs to be fixed:

```sh
pnpm format
```

## Content conventions

- Individual posts live under `posts/*.md`.
- The posts index page is `posts/index.md`.
- Frontmatter commonly includes `title`, `date`, `description`, and `draft`.
- Draft posts are filtered out by `.vitepress/loader/posts.data.ts`.

## Useful implementation notes

- The canonical site URL is defined in `.vitepress/site.ts` and reused by VitePress config.
- Post-specific UI should generally be mounted through the custom theme in `.vitepress/theme/index.ts`.
- The social share toolbar is rendered only on individual post pages via the `doc-footer-before` slot.
- Keep repository instructions in this `AGENTS.md`, and keep it excluded from the published site via `srcExclude`.
