<template>
  <main>
    <section class="hero-section" id="top">
      <div class="hero-copy">
        <p class="eyebrow">
          <span class="eyebrow-dot"></span> {{ t('hero.eyebrow', { ns: 'home' }) }}
        </p>
        <h1>
          {{ t('hero.title', { ns: 'home' }) }}<br /><em>{{
            t('hero.titleEmphasis', { ns: 'home' })
          }}</em>
        </h1>
        <p class="hero-text">
          {{ t('hero.description', { ns: 'home' }) }}
        </p>
        <div class="hero-actions">
          <button class="button button-primary" type="button" @click="emit('open-explore')">
            <span class="explore-label-desktop">{{
              t('hero.exploreTogether', { ns: 'home' })
            }}</span>
            <span class="explore-label-mobile">{{ t('hero.explore', { ns: 'home' }) }}</span>
          </button>

          <RouterLink class="button button-secondary" to="/resources">
            {{ t('hero.resources', { ns: 'home' }) }}
          </RouterLink>
        </div>
      </div>
      <div class="hero-art" :aria-label="t('hero.artAriaLabel', { ns: 'home' })">
        <div class="sun"></div>
        <div class="art-orbit orbit-one"></div>
        <div class="art-orbit orbit-two"></div>
        <div class="stem"></div>
        <div class="leaf leaf-left"></div>
        <div class="leaf leaf-right"></div>
        <div class="flower"><i></i><i></i><i></i><i></i><i></i></div>
        <div
          v-for="card in heroCards"
          :key="card.key"
          class="hero-card"
          :class="card.position"
          tabindex="0"
        >
          <div class="hero-card-inner">
            <div class="hero-card-face hero-card-front">
              <small>{{ card.prompt }}</small>
              <strong>{{ card.title }}</strong>
            </div>
            <div class="hero-card-face hero-card-back">
              <p>{{ card.description }}</p>
              <RouterLink class="hero-card-link" :to="card.to">
                {{ card.link }} <span aria-hidden="true">→</span>
              </RouterLink>
            </div>
          </div>
        </div>
      </div>
    </section>
  </main>
</template>

<script setup lang="ts">
import '../assets/homeView.css'
import { RouterLink } from 'vue-router'

import { computed} from 'vue'

import { useTranslation } from '../i18n/useTranslation'
const { t } = useTranslation()

const emit = defineEmits<{
  (e: 'open-explore'): void
}>()

// Load the content in the 4 cards around the flower
const heroCards = computed(() => [
  {
    key: 'data',
    position: 'card-top-left',
    to: '/data',
    prompt: t('hero.cards.data.prompt', { ns: 'home' }),
    title: t('hero.cards.data.title', { ns: 'home' }),
    description: t('hero.cards.data.description', { ns: 'home' }),
    link: t('hero.cards.data.link', { ns: 'home' }),
  },
  {
    key: 'faq',
    position: 'card-top-right',
    to: '/faq',
    prompt: t('hero.cards.faq.prompt', { ns: 'home' }),
    title: t('hero.cards.faq.title', { ns: 'home' }),
    description: t('hero.cards.faq.description', { ns: 'home' }),
    link: t('hero.cards.faq.link', { ns: 'home' }),
  },
  {
    key: 'gp',
    position: 'card-bottom-left',
    to: '/gpfinder',
    prompt: t('hero.cards.gp.prompt', { ns: 'home' }),
    title: t('hero.cards.gp.title', { ns: 'home' }),
    description: t('hero.cards.gp.description', { ns: 'home' }),
    link: t('hero.cards.gp.link', { ns: 'home' }),
  },
  {
    key: 'guide',
    position: 'card-bottom-right',
    to: '/guide',
    prompt: t('hero.cards.guide.prompt', { ns: 'home' }),
    title: t('hero.cards.guide.title', { ns: 'home' }),
    description: t('hero.cards.guide.description', { ns: 'home' }),
    link: t('hero.cards.guide.link', { ns: 'home' }),
  },
])
</script>
