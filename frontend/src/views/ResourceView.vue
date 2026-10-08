<template>
  <main class="resources-page">
    <header class="resources-hero">
      <p class="section-label">{{ t('page.eyebrow', { ns: 'resources' }) }}</p>
      <h1>
        {{ t('page.title', { ns: 'resources' }) }}<br /><em>{{
          t('page.titleEmphasis', { ns: 'resources' })
        }}</em>
      </h1>
      <p class="resources-lead">{{ t('page.description', { ns: 'resources' }) }}</p>
    </header>

    <div class="resources-body">
      <section v-for="section in sections" :key="section.key" class="resources-section">
        <h2>{{ section.title }}</h2>

        <div class="resource-grid">
          <template v-for="card in section.cards" :key="card.key">
            <RouterLink v-if="!card.external" :to="card.href" class="resource-card">
              <span class="resource-icon" aria-hidden="true">{{ card.icon }}</span>
              <span class="resource-text">
                <strong>{{ card.title }}</strong>
                <small>{{ card.description }}</small>
              </span>
              <span class="resource-arrow" aria-hidden="true">→</span>
            </RouterLink>

            <a
              v-else
              :href="card.href"
              class="resource-card"
              target="_blank"
              rel="noopener noreferrer"
            >
              <span class="resource-icon" aria-hidden="true">{{ card.icon }}</span>
              <span class="resource-text">
                <strong>{{ card.title }}</strong>
                <small>{{ card.description }}</small>
              </span>
              <span class="resource-arrow" aria-hidden="true">↗</span>
              <span class="sr-only">{{ t('notes.external', { ns: 'resources' }) }}</span>
            </a>
          </template>
        </div>
      </section>

      <p class="resources-note">{{ t('notes.disclaimer', { ns: 'resources' }) }}</p>
    </div>
  </main>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink } from 'vue-router'

import { useTranslation } from '../i18n/useTranslation'
const { t } = useTranslation()

const ns = { ns: 'resources' }

// Each card: internal pages use RouterLink, external links open in a new tab.
const sections = computed(() => [
  {
    key: 'support',
    title: t('sections.support', ns),
    cards: [
      {
        key: 'cancerCouncil',
        icon: '✆',
        external: true,
        href: 'https://www.cancer.org.au/support-and-services',
        title: t('cards.cancerCouncil.title', ns),
        description: t('cards.cancerCouncil.description', ns),
      },
      {
        key: 'interpreter',
        icon: '✦',
        external: true,
        href: 'https://www.tisnational.gov.au',
        title: t('cards.interpreter.title', ns),
        description: t('cards.interpreter.description', ns),
      },
      {
        key: 'healthdirect',
        icon: '♡',
        external: true,
        href: 'https://www.healthdirect.gov.au',
        title: t('cards.healthdirect.title', ns),
        description: t('cards.healthdirect.description', ns),
      },
      {
        key: 'ncsr',
        icon: '◌',
        external: true,
        href: 'https://www.ncsr.gov.au',
        title: t('cards.ncsr.title', ns),
        description: t('cards.ncsr.description', ns),
      },
    ],
  },
  {
    key: 'info',
    title: t('sections.info', ns),
    cards: [
      {
        key: 'guide',
        icon: '☰',
        external: true,
        href: 'https://www.cancervic.org.au/about-cancer/prevent-detect-cancer/screening/cervical-screening/self-collection',
        title: t('cards.guide.title', ns),
        description: t('cards.guide.description', ns),
      },
      {
        key: 'program',
        icon: '❀',
        external: true,
        href: 'https://www.health.gov.au/our-work/national-cervical-screening-program',
        title: t('cards.program.title', ns),
        description: t('cards.program.description', ns),
      },
      {
        key: 'cancerCouncilInfo',
        icon: '✿',
        external: true,
        href: 'https://www.cancer.org.au/cancer-information/types-of-cancer/cervical-cancer',
        title: t('cards.cancerCouncilInfo.title', ns),
        description: t('cards.cancerCouncilInfo.description', ns),
      },
    ],
  },
  {
    key: 'site',
    title: t('sections.site', ns),
    cards: [
      {
        key: 'data',
        icon: '◔',
        external: false,
        href: '/data',
        title: t('cards.data.title', ns),
        description: t('cards.data.description', ns),
      },
      {
        key: 'faq',
        icon: '?',
        external: false,
        href: '/faq',
        title: t('cards.faq.title', ns),
        description: t('cards.faq.description', ns),
      },
      {
        key: 'gp',
        icon: '✚',
        external: false,
        href: '/gpfinder',
        title: t('cards.gp.title', ns),
        description: t('cards.gp.description', ns),
      },
    ],
  }
])
</script>

<style scoped>
.resources-page {
  background: #fdf2ef;
}

/* ---------- Header ---------- */
.resources-hero {
  padding: 120px max(6vw, 40px) 70px;
  background: #f8e9e9;
}

.section-label {
  font-size: 11px;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  font-weight: 700;
  color: #b06b70;
}

.resources-hero h1 {
  font-size: clamp(44px, 6vw, 84px);
  line-height: 0.98;
  letter-spacing: -0.06em;
  color: #282326;
  margin: 24px 0;
}

.resources-hero em {
  font-family: Georgia, serif;
  font-weight: 400;
  color: #a75d68;
}

.resources-lead {
  max-width: 520px;
  margin: 0;
  color: #716567;
  font-size: 16px;
  line-height: 1.7;
}

/* ---------- Sections ---------- */
.resources-body {
  padding: 64px max(6vw, 40px) 100px;
}

.resources-section + .resources-section {
  margin-top: 64px;
}

.resources-section h2 {
  margin: 0 0 24px;
  font-size: clamp(22px, 2.4vw, 30px);
  letter-spacing: -0.03em;
  color: #282326;
}

.resource-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
}

/* ---------- Cards ---------- */
.resource-card {
  position: relative;
  display: flex;
  flex-direction: column;
  min-height: 230px;
  box-sizing: border-box;
  padding: 24px 24px 22px;
  background: #fffaf8;
  border: 1px solid #eadedb;
  border-bottom: 4px solid #d47a82;
  border-radius: 18px;
  color: #302a2d;
  text-decoration: none;
  transition:
    transform 0.2s,
    box-shadow 0.2s,
    border-color 0.2s;
}

.resource-card:hover,
.resource-card:focus-visible {
  transform: translateY(-3px);
  border-color: #e3c6c3;
  border-bottom-color: #b9626d;
  box-shadow: 0 12px 26px #7c555522;
  outline: none;
}

.resource-icon {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: #f6e1df;
  color: #b7626d;
  font-size: 20px;
  line-height: 1;
}

.resource-text {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-top: auto;
}

.resource-text strong {
  font-size: 16px;
  line-height: 1.25;
  color: #332a2d;
}

.resource-text small {
  font-size: 12.5px;
  line-height: 1.55;
  color: #806e70;
}

.resource-arrow {
  margin-top: 16px;
  font-size: 20px;
  line-height: 1;
  color: #a75d68;
  transition: transform 0.2s;
}

.resource-card:hover .resource-arrow {
  transform: translateX(4px);
}

[dir='rtl'] .resource-card:hover .resource-arrow {
  transform: translateX(-4px);
}

[dir='rtl'] .resource-arrow {
  display: inline-block;
}

.resources-note {
  margin: 56px 0 0;
  font-size: 12px;
  line-height: 1.6;
  color: #8d7c7e;
}

.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

@media (prefers-reduced-motion: reduce) {
  .resource-card,
  .resource-arrow {
    transition: none;
  }
}

@media (max-width: 960px) {
  .resource-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 620px) {
  .resources-hero {
    padding: 110px 24px 48px;
  }

  .resources-body {
    padding: 44px 24px 80px;
  }

  .resource-grid {
    grid-template-columns: 1fr;
  }

  .resource-card {
    min-height: 190px;
  }
}
</style>
