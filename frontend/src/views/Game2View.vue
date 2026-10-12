<template>
  <main class="game-play-page game2-page">
    <section class="game-stage">
      <section
        ref="gameFrame"
        class="game-frame"
        :aria-label="t('page.ariaLabel', { ns: 'game2' })"
      >
        <iframe
          ref="gameIframe"
          class="game_2"
          :src="`/godot/game2/index.html?v=languages&lang=${initialLanguage}`"
          :title="t('page.iframeTitle', { ns: 'game2' })"
          allowfullscreen
          @load="sendAudioState(); sendLanguage()"
        ></iframe>

        <button
          class="audio-button"
          type="button"
          :aria-label="
            isMuted
              ? t('page.unmute', { ns: 'game2' })
              : t('page.mute', { ns: 'game2' })
          "
          :aria-pressed="isMuted"
          @click="toggleAudio"
        >
          <svg
            class="audio-icon"
            viewBox="0 0 24 24"
            aria-hidden="true"
          >
            <path d="M4 9v6h4l5 4V5L8 9H4Z" />
            <template v-if="isMuted">
              <path d="m17 9 5 5M22 9l-5 5" />
            </template>
            <template v-else>
              <path d="M16 9.5a4 4 0 0 1 0 5M18.5 7a7.5 7.5 0 0 1 0 10" />
            </template>
          </svg>
        </button>

        <button
          class="fullscreen-button"
          type="button"
          :aria-label="
            isFullscreen
              ? t('page.fullscreenExit', { ns: 'game2' })
              : t('page.fullscreenOpen', { ns: 'game2' })
          "
          @click="toggleFullscreen"
        >
          <span class="expand-icon" aria-hidden="true"></span>
        </button>
      </section>

      <div class="game-side">
        <div class="game-side-copy">
          <p class="section-label">
            {{ t('intro.label', { ns: 'game2' }) }}
          </p>

          <h1>
            {{ t('intro.title', { ns: 'game2' }) }}
          </h1>

          <p>
            {{ t('intro.description', { ns: 'game2' }) }}
          </p>
        </div>

        <section class="how-to-play" id="how-to-play">
          <div>
            <p class="section-label">
              {{ t('howToPlay.label', { ns: 'game2' }) }}
            </p>
          </div>

          <div class="guide-steps">
            <article>
              <span>01</span>

              <h3>
                {{ t('howToPlay.steps.watchAndListen.title', { ns: 'game2' }) }}
              </h3>

              <p>
                {{
                  t(
                    'howToPlay.steps.watchAndListen.description',
                    { ns: 'game2' }
                  )
                }}
              </p>
            </article>

            <article>
              <span>02</span>

              <h3>
                {{ t('howToPlay.steps.respondInTime.title', { ns: 'game2' }) }}
              </h3>

              <p>
                {{
                  t(
                    'howToPlay.steps.respondInTime.description',
                    { ns: 'game2' }
                  )
                }}
              </p>
            </article>

            <article>
              <span>03</span>

              <h3>
                {{
                  t(
                    'howToPlay.steps.exploreWhileWaiting.title',
                    { ns: 'game2' }
                  )
                }}
              </h3>

              <p>
                {{
                  t(
                    'howToPlay.steps.exploreWhileWaiting.description',
                    { ns: 'game2' }
                  )
                }}
              </p>
            </article>
          </div>
        </section>

        <div class="game-navigation-links">
          <RouterLink class="game-route-link" to="/gprunner">
            <span aria-hidden="true">←</span>
            {{ t('navigation.game1', { ns: 'game2' }) }}
          </RouterLink>

          <RouterLink
            class="game-route-link game-route-link-next"
            to="/game3"
          >
            {{ t('navigation.game3', { ns: 'game2' }) }}
            <span aria-hidden="true">→</span>
          </RouterLink>
        </div>
      </div>
    </section>
  </main>
</template>

<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import '../assets/gpRunnerGame.css'
import { useTranslation } from '../i18n/useTranslation'
import { useGameLanguage } from '../i18n/useGameLanguage'

const { t } = useTranslation()

const gameFrame = ref<HTMLElement | null>(null)
const gameIframe = ref<HTMLIFrameElement | null>(null)
const { initialLanguage, sendLanguage } = useGameLanguage(gameIframe)
const isFullscreen = ref(false)
const isMuted = ref(false)
const router = useRouter()

const sendAudioState = () => {
  gameIframe.value?.contentWindow?.postMessage(
    { type: 'game2-set-muted', muted: isMuted.value },
    window.location.origin,
  )
}

const toggleAudio = () => {
  isMuted.value = !isMuted.value
  sendAudioState()
}

const toggleFullscreen = async () => {
  if (!document.fullscreenElement) {
    await gameFrame.value?.requestFullscreen()
  } else {
    await document.exitFullscreen()
  }
}

const syncFullscreenState = () => {
  isFullscreen.value = document.fullscreenElement === gameFrame.value
}

const handleGameMessage = (event: MessageEvent) => {
  if (event.origin !== window.location.origin) return
  if (event.source !== gameIframe.value?.contentWindow) return
  if (event.data?.type === 'game2-audio-bridge-ready') {
    sendAudioState()
    return
  }
  if (event.data?.type === 'game2-complete') {
    void router.push('/game3')
  }
}

onMounted(() => {
  window.addEventListener('message', handleGameMessage)
  document.addEventListener('fullscreenchange', syncFullscreenState)
})

onBeforeUnmount(() => {
  window.removeEventListener('message', handleGameMessage)
  document.removeEventListener('fullscreenchange', syncFullscreenState)
})
</script>

<style scoped>
.game2-page .game-frame {
  background: #e8f1ec;
  min-height: 720px;
}

.game2-page {
  height: auto;
  min-height: calc(100dvh - 155px);
  overflow: visible;
}

.game2-page .game-stage {
  height: auto;
  min-height: 720px;
}

.game_2 {
  width: 100%;
  height: 100%;
  border: 0;
  display: block;
}

.game2-page .audio-button {
  position: absolute;
  right: 22px;
  bottom: 66px;
  width: 38px;
  height: 38px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  background: #fffaf8;
  border: 0;
  border-radius: 50%;
  color: #302a2d;
  box-shadow: 0 3px 12px #302a2d18;
  cursor: pointer;
}

.game2-page .audio-button:hover {
  background: #f4e8e4;
}

.audio-icon {
  width: 19px;
  height: 19px;
  fill: currentColor;
  stroke: currentColor;
  stroke-width: 1.8;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.audio-icon > path:first-child {
  stroke: none;
}

@media (max-width: 640px) {
  .game2-page .audio-button {
    right: 16px;
    bottom: 60px;
  }
}

.game2-page .game-navigation-links {
  flex-direction: row;
  flex-wrap: wrap;
}

.game-route-link {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  min-width: 132px;
  padding: 13px 18px;
  border: 1px solid #8e4f59;
  border-radius: 999px;
  background: transparent;
  color: #8e4f59;
  font-size: 12px;
  font-weight: 700;
  text-decoration: none;
  transition: background 0.2s ease, color 0.2s ease, transform 0.2s ease;
}

.game-route-link:hover {
  background: #8e4f59;
  color: #fffaf8;
  transform: translateY(-1px);
}

.game-route-link-next {
  background: #302a2d;
  border-color: #302a2d;
  color: #fffaf8;
}

@media (max-width: 760px) {
  .game2-page {
    height: auto;
    overflow: visible;
  }

  .game2-page .game-stage {
    min-height: 0;
  }

  .game2-page .game-frame {
    width: 100%;
    height: auto;
    min-height: 0;
    aspect-ratio: 16 / 9;
  }
}


/* ==================================================
   Game 2: Theme support for all four buttons
   ================================================== */

/* Blush theme */
.site-shell.theme-blush .game2-page .audio-button,
.site-shell.theme-blush .game2-page .fullscreen-button {
  background: #fffaf8;
  color: #302a2d;
  border: 1px solid #eadfdb;
}

.site-shell.theme-blush .game2-page .audio-button:hover,
.site-shell.theme-blush .game2-page .fullscreen-button:hover {
  background: #f4e8e4;
}

.site-shell.theme-blush .game2-page .game-route-link {
  border-color: #a65364;
  color: #a65364;
}

.site-shell.theme-blush .game2-page .game-route-link:hover {
  background: #f8e9e9;
  color: #8e4f59;
}

.site-shell.theme-blush .game2-page .game-route-link-next {
  background: #a65364;
  border-color: #a65364;
  color: #ffffff;
}

.site-shell.theme-blush .game2-page .game-route-link-next:hover {
  background: #8e4f59;
  border-color: #8e4f59;
  color: #ffffff;
}


/* Teal theme */
.site-shell.theme-teal .game2-page .audio-button,
.site-shell.theme-teal .game2-page .fullscreen-button {
  background: #f3fbfa;
  color: #123b3c;
  border: 1px solid #b8ded9;
}

.site-shell.theme-teal .game2-page .audio-button:hover,
.site-shell.theme-teal .game2-page .fullscreen-button:hover {
  background: #d9f1ee;
}

.site-shell.theme-teal .game2-page .game-route-link {
  border-color: #087b78;
  color: #087b78;
}

.site-shell.theme-teal .game2-page .game-route-link:hover {
  background: #d9f1ee;
  color: #065f5c;
}

.site-shell.theme-teal .game2-page .game-route-link-next {
  background: #087b78;
  border-color: #087b78;
  color: #ffffff;
}

.site-shell.theme-teal .game2-page .game-route-link-next:hover {
  background: #065f5c;
  border-color: #065f5c;
  color: #ffffff;
}


/* Accessible theme */
.site-shell.theme-accessible .game2-page .audio-button,
.site-shell.theme-accessible .game2-page .fullscreen-button {
  background: #ffffff;
  color: #14213d;
  border: 1px solid #a8c7df;
}

.site-shell.theme-accessible .game2-page .audio-button:hover,
.site-shell.theme-accessible .game2-page .fullscreen-button:hover {
  background: #dbe9f7;
}

.site-shell.theme-accessible .game2-page .game-route-link {
  border-color: #145da0;
  color: #145da0;
}

.site-shell.theme-accessible .game2-page .game-route-link:hover {
  background: #dbe9f7;
  color: #0d467b;
}

.site-shell.theme-accessible .game2-page .game-route-link-next {
  background: #145da0;
  border-color: #145da0;
  color: #ffffff;
}

.site-shell.theme-accessible .game2-page .game-route-link-next:hover {
  background: #0d467b;
  border-color: #0d467b;
  color: #ffffff;
}


/* Keyboard focus */
.site-shell .game2-page .audio-button:focus-visible,
.site-shell .game2-page .fullscreen-button:focus-visible,
.site-shell .game2-page .game-route-link:focus-visible {
  outline: 3px solid currentColor;
  outline-offset: 3px;
}

/* Smooth theme transitions */
.game2-page .audio-button,
.game2-page .fullscreen-button,
.game2-page .game-route-link {
  transition:
    background-color 0.2s ease,
    color 0.2s ease,
    border-color 0.2s ease,
    transform 0.2s ease;
}

</style>
