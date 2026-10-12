<template>
  <main class="guide-page">
    <!-- 1. Choose a path -->
    <section class="guide-hero guide-anchor" id="guide-top">
      <div class="guide-hero-inner">
        <p class="eyebrow"> {{ t('hero.eyebrow', ns) }}</p>
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
import { RouterLink } from 'vue-router'

import { useTranslation } from '../i18n/useTranslation'

const { t } = useTranslation()
const ns = { ns: 'guide' }

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

/* =========================================
   Theme colours (Blush is the default)
   ========================================= */
.guide-page {
  --g-page-bg: #fffaf8;
  --g-hero-bg: #f8e9e9;
  --g-home-bg: #fffaf8;
  --g-gp-bg: #fdf2ef;
  --g-ai-bg: #f6e4df;
  --g-heading: #282326;
  --g-body: #6e6263;
  --g-muted: #806e70;
  --g-label: #b06b70;
  --g-accent: #a75d68;
  --g-accent-strong: #8f3f55;
  --g-card-bg: #fffaf6;
  --g-card-border: #eadedb;
  --g-edge: #d47a82;
  --g-edge-hover: #b9626d;
  --g-chip-bg: #f6e1df;
  --g-chip-fg: #b7626d;
  --g-note-bar: #e9b9a8;
  --g-bloom: #efc1b3;
  --g-shadow: #7c555526;
}

.theme-teal .guide-page {
  --g-page-bg: #eaf7f5;
  --g-hero-bg: #d9f1ee;
  --g-home-bg: #f3fbfa;
  --g-gp-bg: #effcfb;
  --g-ai-bg: #d9f1ee;
  --g-heading: #123b3c;
  --g-body: #365e5e;
  --g-muted: #4d7070;
  --g-label: #0b7372;
  --g-accent: #0b7372;
  --g-accent-strong: #075957;
  --g-card-bg: #f5fcfb;
  --g-card-border: #b8ded9;
  --g-edge: #0b7372;
  --g-edge-hover: #075957;
  --g-chip-bg: #c7e8e3;
  --g-chip-fg: #0b7372;
  --g-note-bar: #8ed2cb;
  --g-bloom: #b8ded9;
  --g-shadow: #0b737226;
}

.theme-accessible .guide-page {
  --g-page-bg: #fffdf3;
  --g-hero-bg: #fff1b8;
  --g-home-bg: #fffdf3;
  --g-gp-bg: #fff8dc;
  --g-ai-bg: #fff1b8;
  --g-heading: #14213d;
  --g-body: #354b68;
  --g-muted: #4a5f7d;
  --g-label: #1769aa;
  --g-accent: #1769aa;
  --g-accent-strong: #104b7b;
  --g-card-bg: #fffdf3;
  --g-card-border: #a8c7df;
  --g-edge: #1769aa;
  --g-edge-hover: #104b7b;
  --g-chip-bg: #dbe9f7;
  --g-chip-fg: #1769aa;
  --g-note-bar: #f4c542;
  --g-bloom: #ffe08a;
  --g-shadow: #14213d26;
}

/* =========================================
   Base
   ========================================= */
:global(html) {
  scroll-behavior: smooth;
}

@media (prefers-reduced-motion: reduce) {
  :global(html) {
    scroll-behavior: auto;
  }
}

.guide-page {
  background: var(--g-page-bg);
}

/* Anchor links land just below the 78px sticky header */
.guide-anchor {
  scroll-margin-top: 78px;
}

.guide-page .section-label,
.guide-page .eyebrow {
  color: var(--g-label);
}

.guide-page .eyebrow-dot {
  background: var(--g-edge);
}

.guide-page .arrow-link {
  color: var(--g-accent);
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
  background: var(--g-hero-bg);
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
  color: var(--g-heading);
}

.guide-hero h1 em {
  font-family: Georgia, serif;
  font-weight: 400;
  color: var(--g-accent);
}

.guide-lead {
  max-width: 540px;
  margin: 0 auto;
  color: var(--g-body);
  font-size: 16px;
  line-height: 1.7;
}

.guide-prompt {
  margin: clamp(24px, 4.5vh, 44px) 0 16px;
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: var(--g-accent-strong);
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
  border: 1px solid var(--g-card-border);
  border-bottom: 5px solid var(--g-edge);
  border-radius: 22px;
  background: var(--g-card-bg);
  color: var(--g-heading);
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
  border-bottom-color: var(--g-edge-hover);
  box-shadow: 0 16px 32px var(--g-shadow);
  outline: none;
}

.choice-icon {
  display: grid;
  place-items: center;
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: var(--g-chip-bg);
  color: var(--g-chip-fg);
  font-size: 26px;
  line-height: 1;
}

.choice-text strong {
  display: block;
  font-size: 23px;
  line-height: 1.2;
  color: var(--g-accent-strong);
}

.choice-text small {
  display: block;
  max-width: 300px;
  margin: 8px auto 0;
  font-size: 15px;
  line-height: 1.55;
  color: var(--g-muted);
}

.choice-cta {
  margin-top: auto;
  font-size: 13px;
  font-weight: 700;
  color: var(--g-accent);
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
  background: var(--g-home-bg);
}

.guide-section-gp {
  background: var(--g-gp-bg);
}

.guide-section .intro-grid {
  margin: 18px 0 clamp(24px, 4vh, 44px);
}

.guide-section .intro-grid h2 {
  color: var(--g-heading);
}

.guide-section .intro-grid em {
  color: var(--g-accent);
}

.guide-section .lead {
  color: var(--g-body);
}

.guide-note {
  max-width: 410px;
  margin: 0;
  padding-left: 14px;
  border-left: 3px solid var(--g-note-bar);
  font-size: 13px;
  line-height: 1.6;
  color: var(--g-muted);
}

.guide-section .section-next-link {
  margin-top: auto;
  margin-bottom: 0;
  padding-top: clamp(20px, 4vh, 40px);
  color: var(--g-accent);
}

/* ---------- Flip step cards ---------- */
.step-flip {
  position: relative;
  min-height: 270px;
  perspective: 1200px;
  outline: none;
}

.step-flip:focus-visible {
  outline: 2px solid var(--g-edge);
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
  color: var(--g-chip-fg);
}

.step-front h3 {
  margin: 0;
  max-width: 85%;
  font-size: 21px;
  line-height: 1.2;
  color: var(--g-heading);
}

.step-back {
  gap: 12px;
  transform: rotateY(180deg);
}

.step-back .step-number {
  color: var(--g-accent);
}

.step-back p {
  max-width: 310px;
  margin: 0;
  font-size: 14px;
  line-height: 1.65;
  color: var(--g-body);
}

.flip-hint {
  position: absolute;
  right: 16px;
  bottom: 14px;
  display: grid;
  place-items: center;
  width: 26px;
  height: 26px;
  border: 1px solid var(--g-accent);
  border-radius: 50%;
  font-size: 14px;
  line-height: 1;
  color: var(--g-accent);
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
  background: var(--g-ai-bg);
}

.guide-ai .closing-bloom {
  background: var(--g-bloom);
}

.guide-ai h2 {
  color: var(--g-heading);
}

.guide-ai h2 em {
  color: var(--g-accent);
}

.guide-ai .guide-ai-lead {
  max-width: 560px;
  color: var(--g-body);
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
  color: var(--g-body);
}

.guide-ai-points li span {
  font-weight: 800;
  color: var(--g-chip-fg);
}

.guide-ai .guide-disclaimer {
  margin: 16px auto 0;
  font-size: 12px;
  line-height: 1.6;
  color: var(--g-muted);
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

/* ---------- Luna practice-call assistant ---------- */
.luna-practice-link {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  width: fit-content;
  max-width: 100%;
  margin: 20px auto;
  color: var(--g-accent-strong);
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
  border: 1px solid var(--g-card-border);
  border-radius: 16px;
  background: var(--g-card-bg);
  box-shadow: 0 4px 12px var(--g-shadow);
  color: var(--g-accent-strong);
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
  content: '';
  position: absolute;
  top: 50%;
  left: -7px;
  width: 12px;
  height: 12px;
  border-left: 1px solid var(--g-card-border);
  border-bottom: 1px solid var(--g-card-border);
  background: var(--g-card-bg);
  transform: translateY(-50%) rotate(45deg);
}

.luna-practice-link:hover .luna-doctor-image {
  transform: translateY(-3px);
}

.luna-practice-link:hover .luna-chatbox {
  background: var(--g-hero-bg);
  box-shadow: 0 6px 16px var(--g-shadow);
}

.luna-practice-link:hover .luna-chatbox::before {
  background: var(--g-hero-bg);
}

.luna-practice-link:focus-visible {
  outline: 3px solid var(--g-accent);
  outline-offset: 5px;
  border-radius: 12px;
}

@media (prefers-reduced-motion: reduce) {
  .luna-doctor-image,
  .luna-chatbox {
    transition: none;
  }
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
</style>
