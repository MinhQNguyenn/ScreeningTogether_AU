<template>
  <button
    class="game-music-control"
    type="button"
    :aria-label="muted ? 'Unmute music' : 'Mute music'"
    :title="muted ? 'Unmute music' : 'Mute music'"
    :aria-pressed="muted"
    @click="toggle"
  >
    <span aria-hidden="true">{{ muted ? '♫ ×' : '♫' }}</span>
  </button>
</template>

<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'

const props = defineProps<{ frame: HTMLIFrameElement | null }>()
const muted = ref(false)

function sync() {
  props.frame?.contentWindow?.postMessage(
    { type: 'screening-music-muted', muted: muted.value },
    window.location.origin,
  )
}
function toggle() {
  muted.value = !muted.value
  sync()
}
function receive(event: MessageEvent) {
  if (event.origin !== window.location.origin || event.source !== props.frame?.contentWindow) return
  if (event.data?.type === 'screening-music-ready') sync()
}
watch(() => props.frame, sync)
onMounted(() => window.addEventListener('message', receive))
onBeforeUnmount(() => window.removeEventListener('message', receive))
</script>

<style scoped>
.game-music-control {
  position: absolute;
  top: 68px;
  right: 16px;
  z-index: 10;
  width: 44px;
  height: 44px;
  border: 1px solid #8e4f59;
  border-radius: 50%;
  background: #fffaf8;
  color: #302a2d;
  font-size: 22px;
  cursor: pointer;
}
.game-music-control:focus-visible {
  outline: 3px solid #8e4f59;
  outline-offset: 3px;
}
</style>
