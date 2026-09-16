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
          src="/godot/game2/index.html?v=20260915-1"
          :title="t('page.iframeTitle', { ns: 'game2' })"
          allowfullscreen
        ></iframe>

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

const { t } = useTranslation()

const gameFrame = ref<HTMLElement | null>(null)
const gameIframe = ref<HTMLIFrameElement | null>(null)
const isFullscreen = ref(false)
const router = useRouter()

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
</style>
