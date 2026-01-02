import { createContentLoader } from "vitepress";

const CONTENTS_PATH = "posts/**/*.md";

export default createContentLoader(CONTENTS_PATH, {
  includeSrc: false,
  transform(rawData) {
        return rawData
        .filter((post) => !post.frontmatter.draft && !post.url.endsWith('/posts/'))
  .sort((a, b) => {
    return new Date(b.frontmatter.date).getTime() - new Date(a.frontmatter.date).getTime();
  });
    }
});
