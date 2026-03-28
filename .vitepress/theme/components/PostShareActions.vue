<script setup lang="ts">
import { computed, onBeforeUnmount, ref } from "vue";
import { useData, withBase } from "vitepress";
import { VPButton } from "vitepress/theme";

import { SITE_URL } from "../../site";

const COPY_FEEDBACK_DURATION_MS = 2_000;

const { page } = useData();

const copyStatus = ref<"idle" | "success" | "error">("idle");

let copyFeedbackTimer: ReturnType<typeof setTimeout> | undefined;

const isPostPage = computed(() => {
  return (
    page.value.relativePath.startsWith("posts/") && page.value.relativePath !== "posts/index.md"
  );
});

const postTitle = computed(() => {
  return typeof page.value.frontmatter.title === "string" ? page.value.frontmatter.title : "";
});

const postPath = computed(() => {
  return `/${page.value.relativePath.replace(/\.md$/, "")}`;
});

const postUrl = computed(() => {
  return new URL(withBase(postPath.value), SITE_URL).toString();
});

const xShareUrl = computed(() => {
  const shareUrl = new URL("https://x.com/intent/tweet");

  shareUrl.searchParams.set("url", postUrl.value);

  if (postTitle.value) {
    shareUrl.searchParams.set("text", postTitle.value);
  }

  return shareUrl.toString();
});

function resetCopyStatus() {
  if (copyFeedbackTimer) {
    clearTimeout(copyFeedbackTimer);
  }

  copyFeedbackTimer = setTimeout(() => {
    copyStatus.value = "idle";
  }, COPY_FEEDBACK_DURATION_MS);
}

async function copyLink() {
  if (typeof navigator === "undefined" || !navigator.clipboard?.writeText) {
    copyStatus.value = "error";
    resetCopyStatus();
    return;
  }

  try {
    await navigator.clipboard.writeText(postUrl.value);
    copyStatus.value = "success";
  } catch (error) {
    console.error("Failed to copy post URL.", error);
    copyStatus.value = "error";
  }

  resetCopyStatus();
}

onBeforeUnmount(() => {
  if (copyFeedbackTimer) {
    clearTimeout(copyFeedbackTimer);
  }
});
</script>

<template>
  <div v-if="isPostPage" class="post-share-actions">
    <p class="post-share-actions__label">Share this post</p>

    <div class="post-share-actions__buttons">
      <VPButton theme="brand" text="Share on X" :href="xShareUrl" />

      <VPButton tag="button" theme="alt" text="Copy link" @click="copyLink" />
    </div>

    <p class="post-share-actions__status" :data-state="copyStatus" aria-live="polite">
      {{
        copyStatus === "success"
          ? "Link copied."
          : copyStatus === "error"
            ? "Could not copy the link."
            : ""
      }}
    </p>
  </div>
</template>

<style scoped>
.post-share-actions {
  margin-top: 24px;
}

.post-share-actions__label {
  margin: 0 0 12px;
  color: var(--vp-c-text-2);
  font-size: 14px;
  font-weight: 600;
}

.post-share-actions__buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.post-share-actions__status {
  min-height: 24px;
  margin: 12px 0 0;
  font-size: 14px;
}

.post-share-actions__status[data-state="success"] {
  color: var(--vp-c-brand-1);
}

.post-share-actions__status[data-state="error"] {
  color: var(--vp-c-danger-1);
}
</style>
