<template>
  <main class="game-play-page game3-page">
    <section class="game-stage">
      <section
        ref="gameFrame"
        class="game-frame"
        aria-label="Game 3: Luna's cervical screening appointment"
      >
        <iframe
          class="game_3"
          src="/godot/game3/index.html?v=20260914-17"
          title="A few minutes with Luna"
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
          <p class="section-label">Cervical screening journey | Game 3</p>
          <h1>What happens at screening?</h1>
          <p>
            Join Luna during her appointment, explore her screening choices, and experience how
            quickly the sample collection part can feel.
          </p>
        </div>

        <section class="how-to-play" id="how-to-play">
          <div><p class="section-label">What you will learn</p></div>
          <div class="guide-steps">
            <article>
              <span>01</span>
              <h3>Choices and control</h3>
              <p>
                Help Luna discuss previous screening, sample options, and how to pause or stop.
              </p>
            </article>
            <article>
              <span>02</span>
              <h3>A few minutes</h3>
              <p>
                Solve Luna's picture while the timer shows how a few minutes can pass.
              </p>
            </article>
            <article>
              <span>03</span>
              <h3>After screening</h3>
              <p>Learn what happens to the sample and when screening is usually due again.</p>
            </article>
          </div>
        </section>

        <RouterLink class="previous-game-link" to="/gprunner">
          ← Return to the previous game
        </RouterLink>
      </div>
    </section>
  </main>
</template>

<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import '../assets/gpRunnerGame.css'

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
