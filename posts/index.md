---
# https://vitepress.dev/reference/default-theme-home-page
layout: doc
title: Posts
next: false
prev: false
---

<script setup lang="ts">
import { data as posts } from "../.vitepress/loader/posts.data.ts";
  
const postsByYear = posts.reduce((acc, post) => {
  const year = new Date(post.frontmatter.date).getFullYear();
  
  if (!acc[year]) {
    acc[year] = [];
  }
  
  acc[year].push(post);
  
  return acc;
}, {});

console.log(postsByYear);

const sortedYears = Object.keys(postsByYear).sort((a, b) => b - a);

function formatDate(dateString: string): string {
  return dateString.split('T')[0];
}

</script>

# Posts

<div class="posts-by-year">
<div v-for="year in sortedYears" :key="year" class="year-section">

### {{ year }}

<ul class="posts-list">
<li v-for="post in postsByYear[year]" :key="post.url" class="post-item">
<a :href="post.url">{{ post.frontmatter.title }}</a>
<span class="post-date">{{ formatDate(post.frontmatter.date) }}</span>
</li>
</ul>

</div>
</div>

<style scoped>
.year-section {
  margin-bottom: 3rem;
}

.year-section h3 {
  padding-bottom: 0.5rem;
  border-bottom: 1px solid var(--vp-c-divider);
}

.post-item {
  margin-bottom: 0.5rem;
}

.post-date {
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
  margin-left: 0.5rem;
}
</style>
