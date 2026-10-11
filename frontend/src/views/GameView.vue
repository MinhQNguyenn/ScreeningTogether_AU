<template>
  <main class="game-page">
    <section ref="gameFrame" class="game-frame" aria-label="Educational game area">
        <iframe 
         class="game_1" 
          ref="gameIframe"
          :src="`/godot/screening-game/index.html?v=languages&lang=${initialLanguage}`"
          @load="sendLanguage"
          allowfullscreen
        ></iframe>
      <button
        class="fullscreen-button"
        type="button"
        aria-label="Open game fullscreen"
        @click="toggleFullscreen"
      >
        <span class="icon-wrapper">
          <img src="../assets/expand.png" alt="Expand icon" class="fullscreen-icon" />
        </span>
      </button>
    </section>
    <section class="game-info">
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
      <div class="game-copy">
        <div>
          <p class="section-label">Educational game</p>
          <h2>{{ currentGame.title }}</h2>
        </div>
        <p>{{ currentGame.description }}</p>
      </div>
    </section>
  </main>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useGameLanguage } from '../i18n/useGameLanguage'

const gameIframe = ref<HTMLIFrameElement | null>(null)
const { initialLanguage, sendLanguage } = useGameLanguage(gameIframe)

const gameFrame = ref<HTMLElement | null>(null)
const selectedGame = ref(1)
const isFullscreen = ref(false)
const games = [
  {
    number: 1,
    title: 'Break Through the Barriers',
    description:
      'Navigate common hurdles, fears and stigma around cancer screening to build confidence and take the next step towards getting screened.',
  }
  /*,
  {
    number: 2,
    title: 'Your Screening Journey',
    description:
      'Learn what happens during a screening, understand the steps involved and discover how long the process takes from start to finish.',
  },
  {
    number: 3,
    title: 'Prepare for What Comes Next',
    description:
      'Learn about the steps and support available after a cancer diagnosis, including treatment, follow-up care and other ways to manage your health.',
  },
  */
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

<style scoped>
.game-page {
  background: #fffaf8;
  height: calc(100dvh - 180px);
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  color: #302a2d;
}
.game-frame {
  height: auto;
  min-height: 0;
  flex: 1 1 auto;
  background: #f1f0f0;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}
.game-placeholder {
  text-align: center;
  color: #302a2d;
}
.game-kicker {
  display: block;
  color: #b06b70;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  font-size: 11px;
  font-weight: 700;
  margin-bottom: 22px;
}
.game-placeholder h1 {
  font-size: clamp(55px, 8vw, 108px);
  line-height: 0.9;
  letter-spacing: -0.08em;
  margin: 0;
  font-weight: 700;
}
.game-placeholder p {
  color: #9c9292;
  font-size: 12px;
  margin-top: 18px;
}
.fullscreen-button {
  position: absolute;
  right: 24px;
  bottom: 18px;
  width: 38px;
  height: 38px;
  background: #fffaf8;
  color: #302a2d;
  border: 0;
  border-radius: 50%;
  box-shadow: 0 3px 12px #302a2d18;
  transition: transform 0.2s;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}
.fullscreen-button:hover {
  transform: scale(1.08);
}
.game-frame:fullscreen {
  height: 100vh;
  background: #f1f0f0;
}
.game-frame:fullscreen .game-placeholder h1 {
  font-size: clamp(80px, 14vw, 180px);
}
.game-info {
  flex: 0 0 218px;
  padding: 16px max(6.5vw, 28px) 24px;
}
.game-switcher {
  display: flex;
  justify-content: center;
  gap: 18px;
  margin-bottom: 28px;
}
.game-switcher button {
  height: 24px;
  width: 24px;
  border: 1px solid #302a2d;
  border-radius: 50%;
  background: transparent;
  color: #302a2d;
  font-size: 10px;
  font-weight: 700;
  padding: 0;
}
.game-switcher button.active {
  background: #302a2d;
  color: #fffaf8;
}
.game-copy {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12%;
  align-items: start;
}
.section-label {
  font-size: 10px;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: #b06b70;
  font-weight: 700;
  margin: 0 0 12px;
}
.game-copy h2 {
  font-size: clamp(32px, 4vw, 50px);
  line-height: 1;
  letter-spacing: -0.055em;
  margin: 0;
}
.game-copy > p {
  font-size: 13px;
  line-height: 1.65;
  color: #8b7e80;
  max-width: 370px;
  margin: 0;
  padding-top: 20px;
}
@media (max-width: 760px) {
  .game-frame {
    height: auto;
    min-height: 0;
  }
  .game-info {
    flex-basis: 240px;
    padding-top: 18px;
  }
  .game-copy {
    display: block;
  }
  .game-copy > p {
    padding-top: 16px;
  }
  .game-switcher {
    margin-bottom: 25px;
  }
}
@media (max-width: 760px) {
  .game-page {
    height: calc(100dvh - 220px);
  }
  .game-frame {
    height: auto;
    min-height: 0;
  }
  .game-info {
    flex-basis: 220px;
  }
}
.icon-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 60%; /* Controls how much padding is inside the button */
  height: 60%;
}
.fullscreen-icon {
  width: 100%;
  height: 100%;
  object-fit: contain; /* Keeps expand.png proportioned correctly */
}
.game_1 {
  width: 150%;
  height: 100%;
}
</style>
