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

const copyStatusMessage = computed(() => {
  if (copyStatus.value === "success") {
    return "Copied!";
  }

  if (copyStatus.value === "error") {
    return "Copy failed.";
  }

  return "";
});

onBeforeUnmount(() => {
  if (copyFeedbackTimer) {
    clearTimeout(copyFeedbackTimer);
  }
});
</script>

<template>
  <div v-if="isPostPage" class="post-share-actions">
    <div class="post-share-actions__buttons">
      <VPButton theme="brand" text="Share on X" :href="xShareUrl" />

      <div class="post-share-actions__copy-button">
        <VPButton tag="button" theme="alt" text="Copy link" @click="copyLink" />

        <span
          v-if="copyStatus !== 'idle'"
          class="post-share-actions__tooltip"
          :data-state="copyStatus"
          role="status"
          aria-live="polite"
        >
          {{ copyStatusMessage }}
        </span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.post-share-actions {
  margin-top: 24px;
  padding-top: 24px;
  border-top: 1px solid var(--vp-c-divider);
}

.post-share-actions__buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.post-share-actions__copy-button {
  position: relative;
}

.post-share-actions__tooltip {
  --post-share-tooltip-accent: var(--vp-c-divider);
  position: absolute;
  bottom: calc(100% + 10px);
  left: 50%;
  z-index: 1;
  padding: 6px 10px;
  border: 1px solid var(--post-share-tooltip-accent);
  border-radius: 10px;
  background: var(--vp-c-bg-elv);
  color: var(--vp-c-text-1);
  font-size: 13px;
  line-height: 1.2;
  max-width: min(180px, calc(100vw - 2rem));
  text-align: center;
  white-space: normal;
  pointer-events: none;
  transform: translateX(-50%);
  box-shadow: var(--vp-shadow-2);
}

.post-share-actions__tooltip::after {
  content: "";
  position: absolute;
  bottom: -6px;
  left: 50%;
  width: 10px;
  height: 10px;
  border-right: 1px solid var(--post-share-tooltip-accent);
  border-bottom: 1px solid var(--post-share-tooltip-accent);
  background: var(--vp-c-bg-elv);
  transform: translateX(-50%) rotate(45deg);
}

.post-share-actions__tooltip[data-state="success"] {
  --post-share-tooltip-accent: var(--vp-c-brand-1);
}

.post-share-actions__tooltip[data-state="error"] {
  --post-share-tooltip-accent: var(--vp-c-danger-1);
  color: var(--vp-c-danger-1);
}

@media (max-width: 480px) {
  .post-share-actions__tooltip {
    left: 0;
    transform: none;
  }

  .post-share-actions__tooltip::after {
    left: 24px;
    transform: rotate(45deg);
  }
}
</style>
