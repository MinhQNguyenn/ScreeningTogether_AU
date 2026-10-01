<template>
  <main class="game-play-page">
    <section class="game-stage">
      <section ref="gameFrame" class="game-frame" :aria-label="t('gameArea', { ns: 'gpRunner' })">
        <iframe class="game_1" src="/godot/screening-game/index.html" allowfullscreen></iframe>

        <button
          class="fullscreen-button"
          type="button"
          :aria-label="
            isFullscreen
              ? t('fullscreen.exit', { ns: 'gpRunner' })
              : t('fullscreen.open', { ns: 'gpRunner' })
          "
          @click="toggleFullscreen"
        >
          <span class="expand-icon" aria-hidden="true"></span>
        </button>
      </section>

      <div class="game-side">
        <div class="game-side-copy">
          <p class="section-label">
            {{ t('educationalGame', { ns: 'gpRunner' }) }}
          </p>

          <h1>{{ currentGame.title }}</h1>

          <p>{{ currentGame.description }}</p>
        </div>

        <section class="how-to-play" id="how-to-play">
          <div>
            <p class="section-label">
              {{ t('howToPlay', { ns: 'gpRunner' }) }}
            </p>
          </div>

          <div class="guide-steps">
            <article>
              <span>01</span>

              <h3>
                {{ t('navigation.title', { ns: 'gpRunner' }) }}
              </h3>

              <p>
                {{ t('navigation.description', { ns: 'gpRunner' }) }}
              </p>
            </article>

            <article>
              <span>02</span>

              <h3>
                {{ t('rule.title', { ns: 'gpRunner' }) }}
              </h3>

              <p>
                {{ t('rule.description', { ns: 'gpRunner' }) }}
              </p>
            </article>

            <article>
              <span>03</span>

              <h3>
                {{ t('funFact.title', { ns: 'gpRunner' }) }}
              </h3>

              <p>
                {{ t('funFact.description', { ns: 'gpRunner' }) }}
              </p>
            </article>
          </div>
        </section>
        <div class="game-navigation-links">
          <RouterLink class="next-game-link" to="/game2">
            {{ t('nextGame', { ns: 'gpRunner' }) }}
            <span aria-hidden="true">→</span>
          </RouterLink>
        </div>
        <!-- This part will be implemented when more game is available
        <div class="game-switcher" aria-label="Choose a game">
          <button
            v-for="game in games"
            :key="game.number"
            :class="{ active: selectedGame === game.number }"
            type="button"
            :aria-label="`Open game ${game.number}`"
            @click="selectedGame = game.number"
          >
            {{ game.number }}
          </button>
        </div>
        -->
      </div>
    </section>
  </main>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { RouterLink } from 'vue-router'
import '../assets/gpRunnerGame.css'
import { useTranslation } from '../i18n/useTranslation'

const { t } = useTranslation()

const gameFrame = ref<HTMLElement | null>(null)
const selectedGame = ref(1)
const isFullscreen = ref(false)

const games = computed(() => [
  {
    number: 1,
    title: t('games.knowYourBody.title', { ns: 'gpRunner' }),
    description: t('games.knowYourBody.description', { ns: 'gpRunner' }),
  },
  {
    number: 2,
    title: t('games.throughTheProcess.title', { ns: 'gpRunner' }),
    description: t('games.throughTheProcess.description', { ns: 'gpRunner' }),
  },

  // {
  //   number: 3,
  //   title: t('games.yourPreventionPlan.title', { ns: 'gpRunner' }),
  //   description: t('games.yourPreventionPlan.description', { ns: 'gpRunner' }),
  // },
])

const currentGame = computed(
  () => games.value.find((game) => game.number === selectedGame.value) ?? games.value[0],
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
</script>
