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
          src="/godot/game2/index.html?v=20260916-audio-mute"
          :title="t('page.iframeTitle', { ns: 'game2' })"
          allowfullscreen
          @load="sendAudioState"
        ></iframe>

        <button
          class="audio-button"
          type="button"
          :aria-label="
            isMuted ? t('page.unmute', { ns: 'game2' }) : t('page.mute', { ns: 'game2' })
          "
          :aria-pressed="isMuted"
          @click="toggleAudio"
        >
          <svg class="audio-icon" viewBox="0 0 24 24" aria-hidden="true">
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
                {{ t('howToPlay.steps.watchAndListen.description', { ns: 'game2' }) }}
              </p>
            </article>

            <article>
              <span>02</span>

              <h3>
                {{ t('howToPlay.steps.respondInTime.title', { ns: 'game2' }) }}
              </h3>

              <p>
                {{ t('howToPlay.steps.respondInTime.description', { ns: 'game2' }) }}
              </p>
            </article>

            <article>
              <span>03</span>

              <h3>
                {{ t('howToPlay.steps.exploreWhileWaiting.title', { ns: 'game2' }) }}
              </h3>

              <p>
                {{ t('howToPlay.steps.exploreWhileWaiting.description', { ns: 'game2' }) }}
              </p>
            </article>
          </div>
        </section>

        <div class="game-navigation-links">
          <RouterLink class="game-route-link" to="/gprunner">
            <span aria-hidden="true">←</span>
            {{ t('navigation.game1', { ns: 'game2' }) }}
          </RouterLink>

          <RouterLink class="game-route-link game-route-link-next" to="/game3">
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

const { t } = useTranslation()

const gameFrame = ref<HTMLElement | null>(null)
const gameIframe = ref<HTMLIFrameElement | null>(null)
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
.game2-page {
  background: #fffaf8;
  color: #302a2d;
  min-height: calc(100dvh - 78px);
  height: auto;
  overflow-x: hidden;
} /* ========================= Game frame ========================= */
.game2-page .game-frame {
  position: relative;
  background: #e8f1ec;
  min-width: 0;
  overflow: hidden;
}
.game2-page .game_2 {
  width: 100%;
  height: 100%;
  border: 0;
  display: block;
} /* ========================= Audio button ========================= */
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
  z-index: 5;
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
} /* ========================= Navigation ========================= */
.game2-page .game-navigation-links {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  gap: 10px;
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
  transition:
    background 0.2s ease,
    color 0.2s ease,
    transform 0.2s ease;
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
.game-route-link-next:visited {
  color: #fffaf8;
} /* ========================= Tablet ========================= */
@media (min-width: 761px) and (max-width: 1100px) {
  .game2-page .game-frame {
    min-height: 0;
  }
} /* ========================= Mobile ========================= */
@media (max-width: 760px) {
  .game2-page {
    min-height: 0;
    height: auto;
  } /* * Stack the game and information vertically. */
  .game2-page .game-stage {
    width: 100%;
    min-height: 0;
    height: auto;
    display: flex;
    flex-direction: column;
  } /* ------------------------- Game ------------------------- */
  .game2-page .game-frame {
    width: 100%;
    height: auto; /* * Do not force the game to 720px on mobile. * The game scales according to the phone width. */
    min-height: 0;
    aspect-ratio: 16 / 9;
    flex-shrink: 0;
    overflow: visible;
  }
  .game2-page .game_2 {
    width: 100%;
    height: 100%;
  } /* ------------------------- Audio button ------------------------- */
  .game2-page .audio-button {
    right: 12px;
    bottom: 58px;
    width: 36px;
    height: 36px;
  } /* ------------------------- Side content ------------------------- */
  .game2-page .game-side {
    width: 100%;
    box-sizing: border-box;
    min-height: 0;
    height: auto;
    padding: 32px 20px 32px;
    gap: 28px;
  }
  .game2-page .game-side-copy {
    width: 100%;
  }
  .game2-page .game-side-copy .section-label {
    margin-bottom: 14px;
  }
  .game2-page .game-side-copy h1 {
    font-size: clamp(36px, 11vw, 52px);
    line-height: 0.95;
    letter-spacing: -0.06em;
    margin: 0 0 16px;
    overflow-wrap: anywhere;
  }
  .game2-page .game-side-copy > p:last-child {
    max-width: 100%;
    font-size: 13px;
    line-height: 1.6;
    margin: 0;
  } /* ------------------------- How to play ------------------------- */
  .game2-page .how-to-play {
    width: 100%;
  }
  .game2-page .how-to-play > .section-label {
    margin-bottom: 12px;
  }
  .game2-page .guide-steps {
    width: 100%;
    display: grid;
    grid-template-columns: 1fr;
    gap: 8px;
  }
  .game2-page .guide-steps article {
    min-height: 0;
    padding: 14px;
    box-sizing: border-box;
  }
  .game2-page .guide-steps h3 {
    font-size: 13px;
    margin: 8px 0 5px;
  }
  .game2-page .guide-steps p {
    font-size: 11px;
    line-height: 1.5;
    margin: 0;
  } /* ------------------------- Navigation buttons ------------------------- */
  .game2-page .game-navigation-links {
    width: 100%;
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 8px;
  }
  .game2-page .game-route-link {
    width: 100%;
    min-width: 0;
    box-sizing: border-box;
    padding: 13px 12px;
    font-size: 11px;
    white-space: normal;
    text-align: center;
  }
} /* ========================= Very small phones ========================= */
@media (max-width: 380px) {
  .game2-page .game-side {
    padding-left: 16px;
    padding-right: 16px;
  } /* * Give the Godot game a little more vertical room * on very narrow screens. */
  .game2-page .game-frame {
    aspect-ratio: 4 / 3;
  }
  .game2-page .game-side-copy h1 {
    font-size: 34px;
  }
  .game2-page .game-route-link {
    font-size: 10px;
    padding: 12px 8px;
  }
}
</style>
