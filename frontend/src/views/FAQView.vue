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
        </article>
      </div>
    </section>
  </main>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useTranslation } from '../i18n/useTranslation'
import '../assets/contentPages.css'

const { t } = useTranslation()
const openItem = ref('screening-0')
const groups = [
  {
    key: 'screening',
    items: [
      {
        question: t('questions.what.question', { ns: 'faq' }),
        answer: t('questions.what.answer', { ns: 'faq' }),
      },
      {
        question: t('questions.why.question', { ns: 'faq' }),
        answer: t('questions.why.answer', { ns: 'faq' }),
      },
      {
        question: t('questions.who.question', { ns: 'faq' }),
        answer: t('questions.who.answer', { ns: 'faq' }),
      },
    ],
  },
  {
    key: 'appointment',
    items: [
      {
        question: t('questions.howOften.question', { ns: 'faq' }),
        answer: t('questions.howOften.answer', { ns: 'faq' }),
      },
      {
        question: t('questions.test.question', { ns: 'faq' }),
        answer: t('questions.test.answer', { ns: 'faq' }),
      },
      {
        question: t('questions.femaleClinician.question', { ns: 'faq' }),
        answer: t('questions.femaleClinician.answer', { ns: 'faq' }),
      },
    ],
  },
  {
    key: 'access',
    items: [
      {
        question: t('questions.cost.question', { ns: 'faq' }),
        answer: t('questions.cost.answer', { ns: 'faq' }),
      },
      {
        question: t('questions.selfCollect.question', { ns: 'faq' }),
        answer: t('questions.selfCollect.answer', { ns: 'faq' }),
      },
    ],
  },
]
const toggleItem = (key: string) => {
  openItem.value = openItem.value === key ? '' : key
}
</script>
