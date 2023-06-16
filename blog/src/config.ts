// Place any global data in this file.
// You can import this data from anywhere in your site by using the `import` keyword.

export const SITE_TITLE = "Yudai Fukushima";
export const SITE_DESCRIPTION =
	"Welcome to my website! I write about computer technologies.";
export const TWITTER_HANDLE = "@granddaifuku";
export const MY_NAME = "Yudai Fukushima";

// setup in astro.config.mjs
const BASE_URL = new URL(import.meta.env.SITE);
export const SITE_URL = BASE_URL.origin;
