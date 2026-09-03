<template>
  <main class="game-play-page">
    <section class="game-stage">
      <section ref="gameFrame" class="game-frame" aria-label="Educational game area">
        <iframe
          class="game_1"
          src="/godot/screening-game/index.html"
          allowfullscreen
        ></iframe>
        <button
          class="fullscreen-button"
          type="button"
          :aria-label="isFullscreen ? 'Exit fullscreen' : 'Open game fullscreen'"
          @click="toggleFullscreen"
        >
          <span class="expand-icon" aria-hidden="true"></span>
        </button>
      </section>
      <div class="game-side">
        <div class="game-side-copy">
          <p class="section-label">Educational game</p>
          <h1>{{ currentGame.title }}</h1>
          <p>{{ currentGame.description }}</p>
        </div>
        <section class="how-to-play" id="how-to-play">
          <div><p class="section-label">How to play</p></div>
          <div class="guide-steps">
            <article>
              <span>01</span>
              <h3>Navigation</h3>
              <p>
                Use arrow keys → ← or 'A', 'D' keys to move side by side. And Space, 'W' and ↑ to
                jump
              </p>
            </article>
            <article>
              <span>02</span>
              <h3>Rule</h3>
              <p>
                Try to avoid obstacles and keep at least 1 health before reaching GP. Hitting each
                obstacle costs one health.
              </p>
            </article>
            <article>
              <span>03</span>
              <h3>Fun fact</h3>
              <p>
                Do you know that just by going to cervical screening can help prevent up to 90% of
                cervical cancers?
              </p>
            </article>
          </div>
        </section>
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
        </div> -->
      </div>
    </section>
  </main>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import '../assets/gpRunnerGame.css'

const gameFrame = ref<HTMLElement | null>(null)
const selectedGame = ref(1)
const isFullscreen = ref(false)
const games = [
  {
    number: 1,
    title: 'Know your body',
    description:
      'Cultural beliefs, embarrassment, language barriers and fear of judgement can make cervical screening difficult to talk about. Let’s break the stigma and make screening conversations easier for everyone.',
  },
  // The numbering will be hidden until the game is implemented
  //   {
  //     number: 2,
  //     title: 'Spot the signs',
  //     description:
  //       'Explore the signs to look out for and build confidence in starting a conversation with your healthcare provider.',
  //   },
  //   {
  //     number: 3,
  //     title: 'Your prevention plan',
  //     description:
  //       'Put your knowledge into action by creating a simple, personal plan for your next screening step.',
  //   },
]
const currentGame = computed(
  () => games.find((game) => game.number === selectedGame.value) ?? games[0],
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
