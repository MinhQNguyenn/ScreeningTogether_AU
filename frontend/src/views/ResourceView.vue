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
  },
])
</script>

<style scoped>
.resources-page {
  --resources-bg: #fdf2ef;
  --resources-hero-bg: #f8e9e9;
  --resources-text: #282326;
  --resources-muted: #716567;
  --resources-accent: #a75d68;
  --resources-label: #b06b70;
  --resources-card-bg: #fffaf8;
  --resources-card-border: #eadedb;
  --resources-card-bottom: #d47a82;
  --resources-icon-bg: #f6e1df;
  --resources-icon-color: #b7626d;
  --resources-card-title: #332a2d;
  --resources-card-description: #806e70;
  --resources-note: #8d7c7e;
  --resources-hover-border: #e3c6c3;
  --resources-shadow: #7c555522;

  background: var(--resources-bg);
  color: var(--resources-text);
}

/* Theme colours */
.theme-blush .resources-page {
  --resources-bg: #fdf2ef;
  --resources-hero-bg: #f8e9e9;
  --resources-text: #282326;
  --resources-muted: #716567;
  --resources-accent: #a75d68;
  --resources-label: #b06b70;
  --resources-card-bg: #fffaf8;
  --resources-card-border: #eadedb;
  --resources-card-bottom: #d47a82;
  --resources-icon-bg: #f6e1df;
  --resources-icon-color: #b7626d;
  --resources-card-title: #332a2d;
  --resources-card-description: #806e70;
  --resources-note: #8d7c7e;
  --resources-hover-border: #e3c6c3;
}

.theme-teal .resources-page {
  --resources-bg: #eef8f6;
  --resources-hero-bg: #d9f1ee;
  --resources-text: #193b3a;
  --resources-muted: #496b68;
  --resources-accent: #087b78;
  --resources-label: #0b7372;
  --resources-card-bg: #ffffff;
  --resources-card-border: #c4dfda;
  --resources-card-bottom: #0b7372;
  --resources-icon-bg: #d9f1ee;
  --resources-icon-color: #075957;
  --resources-card-title: #193b3a;
  --resources-card-description: #496b68;
  --resources-note: #557571;
  --resources-hover-border: #65a9a3;
}

.theme-accessible .resources-page {
  --resources-bg: #f0f5fc;
  --resources-hero-bg: #dbe9f7;
  --resources-text: #172b43;
  --resources-muted: #344b63;
  --resources-accent: #145da0;
  --resources-label: #1769aa;
  --resources-card-bg: #ffffff;
  --resources-card-border: #9db7d2;
  --resources-card-bottom: #1769aa;
  --resources-icon-bg: #dbe9f7;
  --resources-icon-color: #104b7b;
  --resources-card-title: #172b43;
  --resources-card-description: #344b63;
  --resources-note: #405975;
  --resources-hover-border: #6e9bc7;
}

/* Header */
.resources-hero {
  padding: 120px max(6vw, 40px) 70px;
  background: var(--resources-hero-bg);
}

.resources-hero .section-label {
  font-size: 11px;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  font-weight: 700;
  color: var(--resources-label);
}

.resources-hero h1 {
  font-size: clamp(44px, 6vw, 84px);
  line-height: 0.98;
  letter-spacing: -0.06em;
  color: var(--resources-text);
  margin: 24px 0;
}

.resources-hero em {
  font-family: Georgia, serif;
  font-weight: 400;
  color: var(--resources-accent);
}

.resources-lead {
  max-width: 520px;
  margin: 0;
  color: var(--resources-muted);
  font-size: 16px;
  line-height: 1.7;
}

/* Sections */
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
  color: var(--resources-text);
}

.resource-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
}

/* Resource cards */
.resource-card {
  position: relative;
  display: flex;
  flex-direction: column;
  min-height: 230px;
  min-width: 0;
  box-sizing: border-box;
  padding: 24px 24px 22px;
  background: var(--resources-card-bg);
  border: 1px solid var(--resources-card-border);
  border-bottom: 4px solid var(--resources-card-bottom);
  border-radius: 18px;
  color: var(--resources-text);
  text-decoration: none;
  overflow-wrap: anywhere;
  transition:
    transform 0.2s,
    box-shadow 0.2s,
    border-color 0.2s;
}

.resource-card:hover,
.resource-card:focus-visible {
  transform: translateY(-3px);
  border-color: var(--resources-hover-border);
  border-bottom-color: var(--resources-accent);
  box-shadow: 0 12px 26px var(--resources-shadow);
}

.resource-card:focus-visible {
  outline: 3px solid var(--resources-accent);
  outline-offset: 3px;
}

.resource-icon {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  flex: 0 0 44px;
  border-radius: 50%;
  background: var(--resources-icon-bg);
  color: var(--resources-icon-color);
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
  line-height: 1.35;
  color: var(--resources-card-title);
  overflow-wrap: anywhere;
}

.resource-text small {
  font-size: 12.5px;
  line-height: 1.55;
  color: var(--resources-card-description);
  overflow-wrap: anywhere;
}

.resource-arrow {
  margin-top: 16px;
  font-size: 20px;
  line-height: 1;
  color: var(--resources-accent);
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
  color: var(--resources-note);
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
