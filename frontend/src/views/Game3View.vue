<template>
  <main class="game-play-page game3-page">
    <section class="game-stage">
      <section
        ref="gameFrame"
        class="game-frame"
        :aria-label="t('aria.gameFrame', { ns: 'game3' })"
      >
        <iframe
          class="game_3"
          src="/godot/game3/index.html?v=20260914-17"
          :title="t('iframe.title', { ns: 'game3' })"
          allowfullscreen
        ></iframe>

        <button
          class="fullscreen-button"
          type="button"
          :aria-label="
            isFullscreen
              ? t('aria.fullscreenExit', { ns: 'game3' })
              : t('aria.fullscreenOpen', { ns: 'game3' })
          "
          @click="toggleFullscreen"
        >
          <span class="expand-icon" aria-hidden="true"></span>
        </button>
      </section>

      <div class="game-side">
        <div class="game-side-copy">
          <p class="section-label">
            {{ t('intro.label', { ns: 'game3' }) }}
          </p>

          <h1>
            {{ t('intro.title', { ns: 'game3' }) }}
          </h1>

          <p>
            {{ t('intro.description', { ns: 'game3' }) }}
          </p>
        </div>

        <section class="how-to-play" id="how-to-play">
          <div>
            <p class="section-label">
              {{ t('learning.label', { ns: 'game3' }) }}
            </p>
          </div>

          <div class="guide-steps">
            <article>
              <span>01</span>

              <h3>
                {{ t('learning.choices.title', { ns: 'game3' }) }}
              </h3>

              <p>
                {{ t('learning.choices.description', { ns: 'game3' }) }}
              </p>
            </article>

            <article>
              <span>02</span>

              <h3>
                {{ t('learning.minutes.title', { ns: 'game3' }) }}
              </h3>

              <p>
                {{ t('learning.minutes.description', { ns: 'game3' }) }}
              </p>
            </article>

            <article>
              <span>03</span>

              <h3>
                {{ t('learning.after.title', { ns: 'game3' }) }}
              </h3>

              <p>
                {{ t('learning.after.description', { ns: 'game3' }) }}
              </p>
            </article>
          </div>
        </section>

        <RouterLink class="previous-game-link" to="/gprunner">
          ← {{ t('navigation.previousGame', { ns: 'game3' }) }}
        </RouterLink>
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
const isFullscreen = ref(false)
const router = useRouter()

const toggleFullscreen = async () => {
  if (!document.fullscreenElement) {
    await gameFrame.value?.requestFullscreen()
    isFullscreen.value = true
  } else {
    await document.exitFullscreen()
    isFullscreen.value = false
  }
}

const handleGameMessage = (event: MessageEvent) => {
  if (event.origin !== window.location.origin) return
  if (event.data?.type === 'game3-complete') {
    void router.push('/gprunner')
  }
}

onMounted(() => window.addEventListener('message', handleGameMessage))
onBeforeUnmount(() => window.removeEventListener('message', handleGameMessage))
</script>

<style scoped>
.game3-page .game-frame {
  background: #f8e9e9;
  min-height: 720px;
}

.game3-page {
  height: auto;
  min-height: calc(100dvh - 155px);
  overflow: visible;
}

.game3-page .game-stage {
  height: auto;
  min-height: 720px;
}

.game_3 {
  width: 100%;
  height: 100%;
  border: 0;
  display: block;
}

.previous-game-link {
  align-self: flex-start;
  color: #8e4f59;
  border-bottom: 1px solid #d8a5aa;
  padding-bottom: 4px;
  font-size: 12px;
  font-weight: 700;
  text-decoration: none;
}

@media (max-width: 760px) {
  .game3-page {
    height: auto;
    overflow: visible;
  }

  .game3-page .game-stage {
    min-height: 0;
  }

  .game3-page .game-frame {
    height: min(85vh, 760px);
    min-height: 600px;
  }
}
</style>
