<template>
  <main class="content-page faq-page">
    <!-- <div class="page-breadcrumb">
      <RouterLink to="/">{{ t('common:header.home') }}</RouterLink
      ><span>/</span>{{ t('title', { ns: 'faq' }) }}
    </div> -->
    <header class="page-heading">
      <p class="section-label">{{ t('eyebrow', { ns: 'faq' }) }}</p>
      <h1>
        {{ t('heading', { ns: 'faq' }) }} <em>{{ t('headingEmphasis', { ns: 'faq' }) }}</em>
      </h1>
      <p>{{ t('intro', { ns: 'faq' }) }}</p>
    </header>
    <section v-for="group in groups" :key="group.key" class="faq-group">
      <h2>{{ t(`groups.${group.key}`, { ns: 'faq' }) }}</h2>
      <div class="faq-list">
        <article
          v-for="(item, index) in group.items"
          :key="item.question"
          :class="['faq-item', { open: openItem === `${group.key}-${index}` }]"
        >
          <button
            type="button"
            :aria-expanded="openItem === `${group.key}-${index}`"
            @click="toggleItem(`${group.key}-${index}`)"
          >
            <span>{{ item.question }}</span
            ><span class="faq-toggle" aria-hidden="true">{{
              openItem === `${group.key}-${index}` ? '−' : '+'
            }}</span>
          </button>
          <p v-if="openItem === `${group.key}-${index}`">{{ item.answer }}</p>
          <RouterLink
  v-if="openItem === `${group.key}-${index}` && item.showArrow"
  :to="item.link || '/learn'"
  class="faq-answer-link"
>
  <span>{{ t('learnMore', { ns: 'faq' }) }}</span>
  <span class="faq-answer-arrow" aria-hidden="true">→</span>
</RouterLink>
        </article>
      </div>
    </section>

    <!-- Cervical result indicator -->
    <section id="result" class="faq-group">
      <h2>{{ t('results.heading', { ns: 'faq' }) }}</h2>
      <div class="faq-list">
        <article
          v-for="(result, index) in results"
          :key="result.key"
          :class="['faq-item', { open: openItem === `result-${index}` }]"
        >
          <button
            type="button"
            :aria-expanded="openItem === `result-${index}`"
            @click="toggleItem(`result-${index}`)"
          >
            <span> {{ t(`results.${result.key}.title`, { ns: 'faq' }) }} </span>
            <span class="faq-toggle" aria-hidden="true">
              {{ openItem === `result-${index}` ? '−' : '+' }}
            </span>
          </button>
          <p v-if="openItem === `result-${index}`">
            {{ t(`results.${result.key}.description`, { ns: 'faq' }) }}
          </p>
          <RouterLink
  v-if="openItem === `result-${index}` && result.showArrow"
  :to="result.link || '/learn'"
  class="faq-answer-link"
>
  <span>{{ t('learnMore', { ns: 'faq' }) }}</span>
  <span class="faq-answer-arrow" aria-hidden="true">→</span>
</RouterLink>
        </article>
      </div>
    </section>
  </main>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useTranslation } from '../i18n/useTranslation'
import '../assets/contentPages.css'
import { RouterLink } from 'vue-router'

const { t } = useTranslation()
const openItem = ref('hpv-0')
const groups = computed(() => [
  {
    key: 'hpv',
    items: [
      {
        question: t('questions.hpv.whatIs.question', { ns: 'faq' }),
        answer: t('questions.hpv.whatIs.answer', { ns: 'faq' }),
        showArrow: false,
      },
      {
        question: t('questions.hpv.howSpread.question', { ns: 'faq' }),
        answer: t('questions.hpv.howSpread.answer', { ns: 'faq' }),
        showArrow: false,
      },
      {
        question: t('questions.hpv.prevention.question', { ns: 'faq' }),
        answer: t('questions.hpv.prevention.answer', { ns: 'faq' }),
        showArrow: false,
      },
      {
        question: t('questions.hpv.positiveResult.question', { ns: 'faq' }),
        answer: t('questions.hpv.positiveResult.answer', { ns: 'faq' }),
        showArrow: true,
        link: '/game1'
      },
    ],
  },
  {
    key: 'screening',
    items: [
      {
        question: t('questions.what.question', { ns: 'faq' }),
        answer: t('questions.what.answer', { ns: 'faq' }),
        showArrow: false,
      },
      {
        question: t('questions.why.question', { ns: 'faq' }),
        answer: t('questions.why.answer', { ns: 'faq' }),
        showArrow: false,
      },
      {
        question: t('questions.who.question', { ns: 'faq' }),
        answer: t('questions.who.answer', { ns: 'faq' }),
        showArrow: true,
        link: '/data'
      },
    ],
  },
  {
    key: 'appointment',
    items: [
      {
        question: t('questions.howOften.question', { ns: 'faq' }),
        answer: t('questions.howOften.answer', { ns: 'faq' }),
        showArrow: false,
      },
      {
        question: t('questions.test.question', { ns: 'faq' }),
        answer: t('questions.test.answer', { ns: 'faq' }),
        showArrow: true,
        link: '/game3'
      },
      {
        question: t('questions.femaleClinician.question', { ns: 'faq' }),
        answer: t('questions.femaleClinician.answer', { ns: 'faq' }),
        showArrow: false,
      },
    ],
  },
  {
    key: 'access',
    items: [
      {
        question: t('questions.cost.question', { ns: 'faq' }),
        answer: t('questions.cost.answer', { ns: 'faq' }),
        showArrow: false,
      },
      {
        question: t('questions.selfCollect.question', { ns: 'faq' }),
        answer: t('questions.selfCollect.answer', { ns: 'faq' }),
        showArrow: true,
        link: '/guide#guide-home'
      },
    ],
  },
])

const results = [
  { key: 'lowRisk', showArrow: false },
  { key: 'intermediateRisk', showArrow: false },
  { key: 'higherRisk', showArrow: false },
  { key: 'unsatisfactory', showArrow: false },
]

const toggleItem = (key: string) => {
  openItem.value = openItem.value === key ? '' : key
}
</script>
