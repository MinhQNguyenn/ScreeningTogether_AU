<template>
  <main class="guide-page">
    <!-- 1. Choose a path -->
    <section class="guide-hero guide-anchor" id="guide-top">
      <div class="guide-hero-inner">
        <p class="eyebrow"><span class="eyebrow-dot"></span> {{ t('hero.eyebrow', ns) }}</p>
        <h1>
          {{ t('hero.title', ns) }}<br /><em>{{ t('hero.titleEmphasis', ns) }}</em>
        </h1>
        <p class="guide-lead">{{ t('hero.description', ns) }}</p>

        <p class="guide-prompt">{{ t('hero.prompt', ns) }}</p>
        <div class="choice-grid" role="group" :aria-label="t('hero.choicesAria', ns)">
          <a
            v-for="choice in choices"
            :key="choice.key"
            :href="`#${choice.target}`"
            class="choice-card"
          >
            <span class="choice-icon" aria-hidden="true">{{ choice.icon }}</span>
            <span class="choice-text">
              <strong>{{ choice.title }}</strong>
              <small>{{ choice.description }}</small>
            </span>
            <span class="choice-cta">{{ choice.cta }} <span aria-hidden="true">↓</span></span>
          </a>
        </div>
      </div>
    </section>

    <!-- 2. From home -->
    <section class="guide-section guide-section-home guide-anchor" id="guide-home">
      <div class="section-label">{{ t('home.label', ns) }}</div>
      <div class="intro-grid">
        <h2>
          {{ t('home.title', ns) }}<br /><em>{{ t('home.titleEmphasis', ns) }}</em>
        </h2>
        <div>
          <p class="lead">{{ t('home.description', ns) }}</p>
          <p class="guide-note">{{ t('home.note', ns) }}</p>
        </div>
      </div>
      <div class="steps-grid">
        <div v-for="(step, index) in homeSteps" :key="step.key" class="step-flip" tabindex="0">
          <div class="step-flip-inner">
            <!-- Front: icon + action -->
            <div class="step-card step-face step-front" :class="{ featured: index === 1 }">
              <div class="step-icon" aria-hidden="true">{{ step.icon }}</div>
              <h3>{{ step.title }}</h3>
              <span class="flip-hint" aria-hidden="true">＋</span>
            </div>

            <!-- Back: detailed guide -->
            <div class="step-card step-face step-back" :class="{ featured: index !== 1 }">
              <span class="step-number">0{{ index + 1 }}</span>
              <p>{{ step.description }}</p>

              <RouterLink
                v-if="index === 2"
                class="arrow-link"
                to="/faq/#result"
                :aria-label="t('navigation.cervicalResults', { ns: 'game3' })"
              >
                {{ t('navigation.cervicalResults', { ns: 'game3' }) }}
                <span aria-hidden="true">→</span>
              </RouterLink>
            </div>
          </div>
        </div>
      </div>
      <a class="section-next-link" href="#guide-ai">
        <span aria-hidden="true">↓</span>{{ t('home.next', ns) }}
      </a>
    </section>

    <!-- 3. At a GP -->
    <section class="guide-section guide-section-gp guide-anchor" id="guide-gp">
      <div class="section-label">{{ t('gp.label', ns) }}</div>
      <div class="intro-grid">
        <h2>
          {{ t('gp.title', ns) }}<br /><em>{{ t('gp.titleEmphasis', ns) }}</em>
        </h2>
        <div>
          <p class="lead">{{ t('gp.description', ns) }}</p>
          <p class="guide-note">{{ t('gp.note', ns) }}</p>
        </div>
      </div>
      <div class="steps-grid">
        <div v-for="(step, index) in gpSteps" :key="step.key" class="step-flip" tabindex="0">
          <div class="step-flip-inner">
            <!-- Front: icon + action -->
            <div class="step-card step-face step-front" :class="{ featured: index === 1 }">
              <div class="step-icon" aria-hidden="true">{{ step.icon }}</div>
              <h3>{{ step.title }}</h3>
              <span class="flip-hint" aria-hidden="true">＋</span>
            </div>

            <!-- Back: detailed guide -->
            <div class="step-card step-face step-back" :class="{ featured: index !== 1 }">
              <span class="step-number">0{{ index + 1 }}</span>
              <p>{{ step.description }}</p>

              <RouterLink
                v-if="index === 2"
                class="arrow-link"
                to="/faq/#result"
                :aria-label="t('navigation.cervicalResults', { ns: 'game3' })"
              >
                {{ t('navigation.cervicalResults', { ns: 'game3' }) }}
                <span aria-hidden="true">→</span>
              </RouterLink>
            </div>
          </div>
        </div>
      </div>
      <RouterLink class="section-next-link section-next-link--out" to="/gpfinder">
        <span aria-hidden="true">→</span>{{ t('gp.next', ns) }}
      </RouterLink>
    </section>

    <!-- 4. AI call practice -->
    <section class="closing-section guide-ai guide-anchor" id="guide-ai">
      <div class="closing-bloom"></div>
      <div class="section-label">{{ t('ai.label', ns) }}</div>
      <h2>
        {{ t('ai.title', ns) }}<br /><em>{{ t('ai.titleEmphasis', ns) }}</em>
      </h2>
      <p class="guide-ai-lead">{{ t('ai.description', ns) }}</p>

      <ul class="guide-ai-points">
        <li v-for="point in aiPoints" :key="point.key">
          <span aria-hidden="true">✓</span>{{ point.text }}
        </li>
      </ul>

      <!-- TODO: point this at the AI call practice feature once it exists -->
      <RouterLink
        to="/call-practice"
        class="luna-practice-link"
        :aria-label="t('ai.practicePrompt', ns)"
      >
        <img src="/luna_doctor.png" alt="" class="luna-doctor-image" />
        <span class="luna-chatbox"> {{ t('ai.practicePrompt', ns) }} </span>
      </RouterLink>

      <p class="guide-disclaimer">
        {{ t('ai.disclaimer', ns) }}<br />{{ t('ai.datadisclaimer', ns) }}
      </p>

      <div class="guide-ai-links">
        <a class="arrow-link" href="#guide-top">{{ t('ai.backToStart', ns) }}</a>
        <RouterLink class="arrow-link" to="/gpfinder">
          {{ t('ai.findGp', ns) }} <span>→</span>
        </RouterLink>
      </div>
    </section>
  </main>
</template>

<script setup lang="ts">
import '../assets/guide.css'
import { computed } from 'vue'
import { RouterLink, useRouter } from 'vue-router'

import { useTranslation } from '../i18n/useTranslation'

const { t } = useTranslation()
const router = useRouter()
const ns = { ns: 'guide' }

// Route of the AI call practice feature (not built yet, update when it exists)
const AI_PRACTICE_ROUTE = '/call-practice'

const startAiPractice = () => {
  router.push(AI_PRACTICE_ROUTE)
}

const choices = computed(() => [
  {
    key: 'home',
    target: 'guide-home',
    icon: '⌂',
    title: t('hero.choices.home.title', ns),
    description: t('hero.choices.home.description', ns),
    cta: t('hero.choices.home.cta', ns),
  },
  {
    key: 'gp',
    target: 'guide-gp',
    icon: '✚',
    title: t('hero.choices.gp.title', ns),
    description: t('hero.choices.gp.description', ns),
    cta: t('hero.choices.gp.cta', ns),
  },
])

const homeSteps = computed(() => [
  {
    key: 'call',
    icon: '✆',
    title: t('home.steps.call.title', ns),
    description: t('home.steps.call.description', ns),
  },
  {
    key: 'collect',
    icon: '✦',
    title: t('home.steps.collect.title', ns),
    description: t('home.steps.collect.description', ns),
  },
  {
    key: 'return',
    icon: '◌',
    title: t('home.steps.return.title', ns),
    description: t('home.steps.return.description', ns),
  },
])

const gpSteps = computed(() => [
  {
    key: 'book',
    icon: '☰',
    title: t('gp.steps.book.title', ns),
    description: t('gp.steps.book.description', ns),
  },
  {
    key: 'test',
    icon: '✚',
    title: t('gp.steps.test.title', ns),
    description: t('gp.steps.test.description', ns),
  },
  {
    key: 'result',
    icon: '◌',
    title: t('gp.steps.result.title', ns),
    description: t('gp.steps.result.description', ns),
  },
])

const aiPoints = computed(() => [
  { key: 'ask', text: t('ai.points.ask', ns) },
  { key: 'questions', text: t('ai.points.questions', ns) },
  { key: 'next', text: t('ai.points.next', ns) },
])
</script>

<style scoped>
:global(html) {
  scroll-behavior: smooth;
}

@media (prefers-reduced-motion: reduce) {
  :global(html) {
    scroll-behavior: auto;
  }
}

.guide-page {
  background: #fffaf8;
}

/* Anchor links land just below the 78px sticky header */
.guide-anchor {
  scroll-margin-top: 78px;
}

/* ---------- 1. Hero / choice ---------- */
.guide-hero {
  display: flex;
  align-items: center;
  justify-content: center;
  box-sizing: border-box;
  min-height: calc(100vh - 78px);
  min-height: calc(100dvh - 78px);
  padding: clamp(24px, 5vh, 56px) max(6vw, 40px);
  background: #f8e9e9;
  text-align: center;
}

.guide-hero-inner {
  width: 100%;
  max-width: 980px;
  margin: 0 auto;
}

.guide-hero .eyebrow {
  justify-content: center;
}

.guide-hero h1 {
  margin: clamp(14px, 2.5vh, 24px) 0;
  font-size: clamp(40px, 5.5vw, 72px);
  font-weight: 700;
  line-height: 0.98;
  letter-spacing: -0.065em;
  color: #282326;
}

.guide-hero h1 em {
  font-family: Georgia, serif;
  font-weight: 400;
  color: #a75d68;
}

.guide-lead {
  max-width: 540px;
  margin: 0 auto;
  color: #6e6263;
  font-size: 16px;
  line-height: 1.7;
}

.guide-prompt {
  margin: clamp(24px, 4.5vh, 44px) 0 16px;
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: #8f3f55;
}

.choice-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 20px;
  max-width: 900px;
  margin: 0 auto;
}

.choice-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 18px;
  min-height: 250px;
  box-sizing: border-box;
  padding: 32px 28px 26px;
  border: 1px solid #eadedb;
  border-bottom: 5px solid #d47a82;
  border-radius: 22px;
  background: #fffaf6;
  color: #302a2d;
  text-align: center;
  text-decoration: none;
  transition:
    transform 0.2s,
    box-shadow 0.2s,
    border-color 0.2s;
}

.choice-card:hover,
.choice-card:focus-visible {
  transform: translateY(-4px);
  border-bottom-color: #b9626d;
  box-shadow: 0 16px 32px #7c555526;
  outline: none;
}

.choice-icon {
  display: grid;
  place-items: center;
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: #f6e1df;
  color: #b7626d;
  font-size: 26px;
  line-height: 1;
}

.choice-text strong {
  display: block;
  font-size: 23px;
  line-height: 1.2;
  color: #8f3f55;
}

.choice-text small {
  display: block;
  max-width: 300px;
  margin: 8px auto 0;
  font-size: 15px;
  line-height: 1.55;
  color: #806e70;
}

.choice-cta {
  margin-top: auto;
  font-size: 13px;
  font-weight: 700;
  color: #a75d68;
}

/* ---------- 2 + 3. Option sections ---------- */
.guide-section {
  display: flex;
  flex-direction: column;
  justify-content: center;
  box-sizing: border-box;
  min-height: calc(100vh - 78px);
  min-height: calc(100dvh - 78px);
  padding: clamp(40px, 7vh, 80px) max(6vw, 40px) clamp(24px, 4vh, 48px);
}

.guide-section-home {
  background: #fffaf8;
}

.guide-section-gp {
  background: #fdf2ef;
}

.guide-section .intro-grid {
  margin: 18px 0 clamp(24px, 4vh, 44px);
}

.guide-note {
  max-width: 410px;
  margin: 0;
  padding-left: 14px;
  border-left: 3px solid #e9b9a8;
  font-size: 13px;
  line-height: 1.6;
  color: #8d7c7e;
}

.guide-section .section-next-link {
  margin-top: auto;
  margin-bottom: 0;
  padding-top: clamp(20px, 4vh, 40px);
}

/* ---------- Flip step cards ---------- */
.step-flip {
  position: relative;
  min-height: 270px;
  perspective: 1200px;
  outline: none;
}

.step-flip:focus-visible {
  outline: 2px solid #e9b9a8;
  outline-offset: 4px;
}

.step-flip-inner {
  position: absolute;
  inset: 0;
  transform-style: preserve-3d;
  transition: transform 0.6s ease;
}

.step-flip:hover .step-flip-inner,
.step-flip:focus-within .step-flip-inner {
  transform: rotateY(180deg);
}

.step-face {
  position: absolute;
  inset: 0;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 14px;
  min-height: 0;
  padding: 28px 26px;
  text-align: center;
  backface-visibility: hidden;
  -webkit-backface-visibility: hidden;
}

.step-front .step-icon {
  margin: 0;
  font-size: 46px;
}

.step-front h3 {
  margin: 0;
  max-width: 85%;
  font-size: 21px;
  line-height: 1.2;
}

.step-back {
  gap: 12px;
  transform: rotateY(180deg);
}

.step-back p {
  max-width: 310px;
  margin: 0;
  font-size: 14px;
  line-height: 1.65;
}

.flip-hint {
  position: absolute;
  right: 16px;
  bottom: 14px;
  display: grid;
  place-items: center;
  width: 26px;
  height: 26px;
  border: 1px solid #b77b84;
  border-radius: 50%;
  font-size: 14px;
  line-height: 1;
  color: #a75d68;
}

@media (prefers-reduced-motion: reduce) {
  .step-flip-inner {
    transition: none;
  }
}

/* Arrow that leaves the page nudges sideways instead of down */
.section-next-link--out span {
  animation-name: guide-arrow-nudge;
}

@keyframes guide-arrow-nudge {
  0%,
  100% {
    transform: translateX(0);
  }

  50% {
    transform: translateX(5px);
  }
}

@media (prefers-reduced-motion: reduce) {
  .section-next-link--out span {
    animation: none;
  }

  .choice-card {
    transition: none;
  }
}

/* ---------- 4. AI call practice ---------- */
.guide-ai {
  display: flex;
  flex-direction: column;
  justify-content: center;
  box-sizing: border-box;
  min-height: calc(100vh - 78px);
  min-height: calc(100dvh - 78px);
}

.guide-ai .guide-ai-lead {
  max-width: 560px;
}

.guide-ai-points {
  display: grid;
  gap: 10px;
  max-width: 420px;
  margin: 0 auto 32px;
  padding: 0;
  list-style: none;
  text-align: left;
  position: relative;
}

.guide-ai-points li {
  display: flex;
  gap: 10px;
  font-size: 14px;
  line-height: 1.5;
  color: #6e5558;
}

.guide-ai-points li span {
  font-weight: 800;
  color: #b7626d;
}

.guide-ai .guide-disclaimer {
  margin: 16px auto 0;
  font-size: 12px;
  line-height: 1.6;
  color: #8d7c7e;
}

.guide-ai-links {
  position: relative;
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 10px 28px;
  margin-top: 26px;
}

.guide-ai-links .arrow-link {
  margin-top: 0;
}

.guide-ai .button {
  justify-content: center;
  gap: 8px;
  padding: 11px 22px;
  font-size: 12px;
}

.guide-ai .button span {
  font-size: 15px;
  line-height: 1;
}

/* ---------- Responsive ---------- */
@media (max-width: 760px) {
  .guide-hero {
    padding-left: 24px;
    padding-right: 24px;
  }

  .choice-grid {
    grid-template-columns: 1fr;
  }

  .choice-card {
    min-height: 0;
    padding: 24px 20px 20px;
  }

  .guide-section {
    justify-content: flex-start;
    padding-left: 24px;
    padding-right: 24px;
  }

  .step-flip {
    min-height: 220px;
  }
}


/* Luna practice-call assistant */
.luna-practice-link {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  width: fit-content;
  max-width: 100%;
  margin: 20px auto;
  color: #8f3f55;
  text-decoration: none;
  cursor: pointer;
}

.luna-doctor-image {
  display: block;
  width: 85px;
  height: 95px;
  flex-shrink: 0;
  object-fit: contain;
  transition: transform 0.2s ease;
}

.luna-chatbox {
  position: relative;
  display: block;
  max-width: 210px;
  padding: 12px 16px;
  border: 1px solid #ead3d3;
  border-radius: 16px;
  background: #fffaf6;
  box-shadow: 0 4px 12px #7c55551a;
  color: #8f3f55;
  font-size: 13px;
  font-weight: 600;
  line-height: 1.5;
  text-align: left;
  transition:
    background 0.2s ease,
    box-shadow 0.2s ease;
}

/* Small pointer connecting the bubble to Luna */
.luna-chatbox::before {
  content: "";
  position: absolute;
  top: 50%;
  left: -7px;
  width: 12px;
  height: 12px;
  border-left: 1px solid #ead3d3;
  border-bottom: 1px solid #ead3d3;
  background: #fffaf6;
  transform: translateY(-50%) rotate(45deg);
}

.luna-practice-link:hover .luna-doctor-image {
  transform: translateY(-3px);
}

.luna-practice-link:hover .luna-chatbox {
  background: #f8e9e9;
  box-shadow: 0 6px 16px #7c555526;
}

.luna-practice-link:focus-visible {
  outline: 3px solid #b7626d;
  outline-offset: 5px;
  border-radius: 12px;
}

@media (max-width: 480px) {
  .luna-doctor-image {
    width: 68px;
    height: 78px;
  }

  .luna-chatbox {
    max-width: 190px;
    padding: 10px 12px;
    font-size: 12px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .luna-doctor-image,
  .luna-chatbox {
    transition: none;
  }
}

</style>
