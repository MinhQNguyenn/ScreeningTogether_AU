<template>
  <main class="game-play-page game2-page">
    <section class="game-stage">
      <section
        ref="gameFrame"
        class="game-frame"
        aria-label="Game 2: waiting room listening practice"
      >
        <iframe
          ref="gameIframe"
          class="game_2"
          src="/godot/game2/index.html?v=20260916-3"
          title="Waiting Room Listening Practice"
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
          <p class="section-label">Screening appointment | Game 2</p>
          <h1>Listen for your name</h1>
          <p>
            Practise staying aware in a busy waiting room, recognise when your name is called,
            and explore useful support while you wait.
          </p>
        </div>

        <section class="how-to-play" id="how-to-play">
          <div>
            <p class="section-label">How to play</p>
          </div>

          <div class="guide-steps">
            <article>
              <span>01</span>
              <h3>Watch and listen</h3>
              <p>Names move across the blue announcement screen one at a time.</p>
            </article>

            <article>
              <span>02</span>
              <h3>Respond in time</h3>
              <p>Select That's Me only when your full name appears.</p>
            </article>

            <article>
              <span>03</span>
              <h3>Explore while waiting</h3>
              <p>Find useful objects and information to complete optional side quests.</p>
            </article>
          </div>
        </section>

        <div class="game-navigation-links">
          <RouterLink class="game-route-link" to="/gprunner">
            <span aria-hidden="true">←</span>
            Game 1
          </RouterLink>

          <RouterLink class="game-route-link game-route-link-next" to="/game3">
            Game 3
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
