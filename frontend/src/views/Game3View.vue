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
          :key="variant"
          :src="gameSource"
          ref="gameIframe"
          @load="sendLanguage"
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
        <!-- <nav class="variant-picker" :aria-label="t('aria.variantPicker', { ns: 'game3' })">
          <p>
            {{ t('variant.description', { ns: 'game3' }) }}
          </p>

          <RouterLink
            :to="{ path: '/game3', query: { variant: 'animation' } }"
            :aria-current="variant === 'animation' ? 'page' : undefined"
          >
            {{ t('variant.animation', { ns: 'game3' }) }}
          </RouterLink>

          <RouterLink
            :to="{ path: '/game3', query: { variant: 'puzzle' } }"
            :aria-current="variant === 'puzzle' ? 'page' : undefined"
          >
            {{ t('variant.puzzle', { ns: 'game3' }) }}
          </RouterLink>
        </nav> -->
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
                {{
                  variant === 'animation'
                    ? t('learning.minutes.animationDescription', { ns: 'game3' })
                    : t('learning.minutes.puzzleDescription', { ns: 'game3' })
                }}
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
        <div class="game-navigation-links">
          <RouterLink class="game-route-link" to="/game2">
            <span aria-hidden="true">←</span>
            {{ t('navigation.previousGame', { ns: 'game3' }) }}
          </RouterLink>

          <RouterLink
            class="game-route-link game-route-link-next"
            to="/faq/#result"
          >
            {{ t('navigation.cervicalResults', { ns: 'game3' }) }}
            <span aria-hidden="true">→</span>
          </RouterLink>
        </div>
      </div>
    </section>
  </main>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import '../assets/gpRunnerGame.css'
import { useTranslation } from '../i18n/useTranslation'
import { useGameLanguage } from '../i18n/useGameLanguage'

const { t } = useTranslation()

const gameFrame = ref<HTMLElement | null>(null)
const isFullscreen = ref(false)
const router = useRouter()
const route = useRoute()
const gameIframe = ref<HTMLIFrameElement | null>(null)
const { initialLanguage, sendLanguage } = useGameLanguage(gameIframe)
const variant = computed(() => (route.query.variant === 'puzzle' ? 'puzzle' : 'animation'))
const gameSource = computed(
  () => `/godot/game3/index.html?v=languages&variant=${variant.value}&lang=${initialLanguage}`,
)

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
  if (event.origin !== window.location.origin || event.source !== gameIframe.value?.contentWindow)
    return
  if (event.data?.type === 'game3-complete') {
    void router.push('/gprunner')
  }
}

const syncFullscreen = () => {
  isFullscreen.value = document.fullscreenElement === gameFrame.value
}
onMounted(() => {
  window.addEventListener('message', handleGameMessage)
  document.addEventListener('fullscreenchange', syncFullscreen)
})
onBeforeUnmount(() => {
  window.removeEventListener('message', handleGameMessage)
  document.removeEventListener('fullscreenchange', syncFullscreen)
})
</script>

<style scoped>
.variant-picker {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}
.variant-picker p {
  flex-basis: 100%;
  font-size: 13px;
  margin: 0;
}
.variant-picker a {
  padding: 10px 14px;
  border: 2px solid #8e4f59;
  border-radius: 6px;
  color: #8e4f59;
  text-decoration: none;
  font-size: 13px;
}
.variant-picker a[aria-current='page'] {
  background: #302a2d;
  border-color: #302a2d;
  color: white;
}
.variant-picker a:focus-visible {
  outline: 3px solid #d5a653;
  outline-offset: 3px;
}
.game3-page .fullscreen-button {
  top: 16px;
  bottom: auto;
}
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

.game-navigation-links {
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


/* ==================================================
   Game 3: Theme support
   ================================================== */

/* Blush theme */
.site-shell.theme-blush .game3-page .fullscreen-button {
  background: #fffaf8;
  color: #302a2d;
  border: 1px solid #eadfdb;
}

.site-shell.theme-blush .game3-page .fullscreen-button:hover {
  background: #f4e8e4;
}

.site-shell.theme-blush .game3-page .game-route-link {
  background: transparent;
  border-color: #a65364;
  color: #a65364;
}

.site-shell.theme-blush .game3-page .game-route-link:hover {
  background: #f8e9e9;
  border-color: #8e4f59;
  color: #8e4f59;
}

.site-shell.theme-blush .game3-page .game-route-link-next {
  background: #a65364;
  border-color: #a65364;
  color: #ffffff;
}

.site-shell.theme-blush .game3-page .game-route-link-next:hover {
  background: #8e4f59;
  border-color: #8e4f59;
  color: #ffffff;
}


/* Teal theme */
.site-shell.theme-teal .game3-page .fullscreen-button {
  background: #f3fbfa;
  color: #123b3c;
  border: 1px solid #b8ded9;
}

.site-shell.theme-teal .game3-page .fullscreen-button:hover {
  background: #d9f1ee;
}

.site-shell.theme-teal .game3-page .game-route-link {
  background: transparent;
  border-color: #087b78;
  color: #087b78;
}

.site-shell.theme-teal .game3-page .game-route-link:hover {
  background: #d9f1ee;
  border-color: #065f5c;
  color: #065f5c;
}

.site-shell.theme-teal .game3-page .game-route-link-next {
  background: #087b78;
  border-color: #087b78;
  color: #ffffff;
}

.site-shell.theme-teal .game3-page .game-route-link-next:hover {
  background: #065f5c;
  border-color: #065f5c;
  color: #ffffff;
}


/* Accessible theme */
.site-shell.theme-accessible .game3-page .fullscreen-button {
  background: #ffffff;
  color: #14213d;
  border: 1px solid #a8c7df;
}

.site-shell.theme-accessible .game3-page .fullscreen-button:hover {
  background: #dbe9f7;
}

.site-shell.theme-accessible .game3-page .game-route-link {
  background: transparent;
  border-color: #145da0;
  color: #145da0;
}

.site-shell.theme-accessible .game3-page .game-route-link:hover {
  background: #dbe9f7;
  border-color: #0d467b;
  color: #0d467b;
}

.site-shell.theme-accessible .game3-page .game-route-link-next {
  background: #145da0;
  border-color: #145da0;
  color: #ffffff;
}

.site-shell.theme-accessible .game3-page .game-route-link-next:hover {
  background: #0d467b;
  border-color: #0d467b;
  color: #ffffff;
}


/* Keyboard focus */
.site-shell .game3-page .fullscreen-button:focus-visible,
.site-shell .game3-page .game-route-link:focus-visible {
  outline: 3px solid currentColor;
  outline-offset: 3px;
}

/* Smooth theme transitions */
.game3-page .fullscreen-button,
.game3-page .game-route-link {
  transition:
    background-color 0.2s ease,
    color 0.2s ease,
    border-color 0.2s ease,
    transform 0.2s ease;
}

</style>
