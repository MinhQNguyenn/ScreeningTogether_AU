<template>
  <main>
    <section class="intro-section" id="learn">
      <div class="section-label">{{ t('essentials.label', { ns: 'home' }) }}</div>
      <div class="intro-grid">
        <h2>
          {{ t('essentials.title', { ns: 'home' }) }}<br /><em>{{
            t('essentials.titleEmphasis', { ns: 'home' })
          }}</em>
        </h2>
        <div>
          <p class="lead">
            {{ t('essentials.description', { ns: 'home' }) }}
          </p>
          <a class="arrow-link" href="#screening-info"
            >{{ t('essentials.faqLink', { ns: 'home' }) }} <span>→</span></a
          >
        </div>
      </div>
      <div class="faq-preview-grid">
        <RouterLink class="faq-preview-card" to="/faq">
          <span>{{ t('screening.cards.what.title', { ns: 'home' }) }}</span>
          <small>{{ t('screening.preview.first', { ns: 'home' }) }}</small>
          <span class="faq-plus" aria-hidden="true">＋</span>
        </RouterLink>
        <RouterLink class="faq-preview-card" to="/faq">
          <span>{{ t('screening.cards.why.title', { ns: 'home' }) }}</span>
          <small>{{ t('screening.preview.second', { ns: 'home' }) }}</small>
          <span class="faq-plus" aria-hidden="true">＋</span>
        </RouterLink>
      </div>

      <a class="section-next-link" href="#screening-info">
        <span aria-hidden="true">↓</span>{{ t('essentials.nextSection', { ns: 'home' }) }}
      </a>
    </section>

    <section class="screening-info faq-preview" id="screening-info">
      <div class="section-label">{{ t('screening.label', { ns: 'home' }) }}</div>
      <div class="screening-info-heading">
        <h2>
          {{ t('screening.title', { ns: 'home' }) }}<br /><em>{{
            t('screening.titleEmphasis', { ns: 'home' })
          }}</em>
        </h2>
        <p>{{ t('screening.description', { ns: 'home' }) }}</p>
      </div>
      <div class="steps-grid" id="steps">
        <article class="step-card">
          <span class="step-number">01</span>
          <div class="step-icon icon-shield">♡</div>
          <h3>{{ t('essentials.steps.vaccination.title', { ns: 'home' }) }}</h3>
          <p>
            {{ t('essentials.steps.vaccination.description', { ns: 'home' }) }}
          </p>
        </article>
        <article class="step-card featured">
          <span class="step-number">02</span>
          <div class="step-icon">◌</div>
          <h3>{{ t('essentials.steps.screening.title', { ns: 'home' }) }}</h3>
          <p>{{ t('essentials.steps.screening.description', { ns: 'home' }) }}</p>
        </article>
        <article class="step-card">
          <span class="step-number">03</span>
          <div class="step-icon">✦</div>
          <h3>{{ t('essentials.steps.body.title', { ns: 'home' }) }}</h3>
          <p>
            <strong>{{ t('essentials.steps.body.highlight', { ns: 'home' }) }}</strong>
            {{ t('essentials.steps.body.description', { ns: 'home' }) }}
          </p>
        </article>
      </div>
      <RouterLink class="arrow-link faq-all-link" to="/faq">
        {{ t('screening.seeAll', { ns: 'home' }) }} <span>→</span>
      </RouterLink>
      <a class="section-next-link" href="#stats">
        <span aria-hidden="true">↓</span>{{ t('screening.nextSection', { ns: 'home' }) }}
      </a>
    </section>

    <section class="stats-section" id="stats">
      <div class="stats-heading">
        <div>
          <div class="section-label light">{{ t('stats.label', { ns: 'home' }) }}</div>
          <h2>
            {{ t('stats.title', { ns: 'home' }) }}<br /><em>{{
              t('stats.titleEmphasis', { ns: 'home' })
            }}</em>
          </h2>
        </div>
      </div>
      <div class="steps-grid" id="steps">
        <article class="step-card">
          <span class="step-number">01</span>
          <div class="step-icon icon-shield">♡</div>
          <h3>{{ t('essentials.steps.vaccination.title', { ns: 'home' }) }}</h3>
          <p>
            {{ t('essentials.steps.vaccination.description', { ns: 'home' }) }}
          </p>
        </article>
        <article class="step-card featured">
          <span class="step-number">02</span>
          <div class="step-icon">◌</div>
          <h3>{{ t('essentials.steps.screening.title', { ns: 'home' }) }}</h3>
          <p>{{ t('essentials.steps.screening.description', { ns: 'home' }) }}</p>
        </article>
        <article class="step-card">
          <span class="step-number">03</span>
          <div class="step-icon">✦</div>
          <h3>{{ t('essentials.steps.body.title', { ns: 'home' }) }}</h3>
          <p>
            <strong>{{ t('essentials.steps.body.highlight', { ns: 'home' }) }}</strong>
            {{ t('essentials.steps.body.description', { ns: 'home' }) }}
          </p>
        </article>
      </div>
      <RouterLink class="arrow-link stats-data-link" to="/data">
        {{ t('stats.seeData', { ns: 'home' }) }} <span>→</span>
      </RouterLink>
      <a class="section-next-link" href="#closing">
        <span aria-hidden="true">↓</span>{{ t('stats.nextSection', { ns: 'home' }) }}
      </a>
    </section>

    <section class="closing-section" id="closing">
      <div class="closing-bloom"></div>
      <div class="section-label">{{ t('closing.label', { ns: 'home' }) }}</div>
      <h2>
        {{ t('closing.title', { ns: 'home' }) }}<br /><em>{{
          t('closing.titleEmphasis', { ns: 'home' })
        }}</em>
      </h2>
      <p>{{ t('closing.description', { ns: 'home' }) }}</p>
      <RouterLink to="/gpfinder" class="button button-primary">{{
        t('closing.checkGp', { ns: 'home' })
      }}</RouterLink>
    </section>
  </main>
</template>

<script setup lang="ts">
import '../assets/guide.css'
import { RouterLink, useRoute, useRouter } from 'vue-router'

import { computed, onMounted, ref, watch } from 'vue'

import {
  getParticipationGraph,
  getParticipationPercentage,
  type ParticipationGraph,
  type ParticipationPercentage,
} from '../api/stats'

import { useTranslation } from '../i18n/useTranslation'
const { t } = useTranslation()

const emit = defineEmits<{
  (e: 'open-explore'): void
}>()

const route = useRoute()
const router = useRouter()

const states = computed(() => [
  {
    label: t('states.all', { ns: 'home' }),
    value: 'Australia',
  },
  {
    label: t('states.victoria', { ns: 'home' }),
    value: 'Vic',
  },
  {
    label: t('states.newSouthWales', { ns: 'home' }),
    value: 'NSW',
  },
  {
    label: t('states.queensland', { ns: 'home' }),
    value: 'Qld',
  },
  {
    label: t('states.westernAustralia', { ns: 'home' }),
    value: 'WA',
  },
  {
    label: t('states.southAustralia', { ns: 'home' }),
    value: 'SA',
  },
  {
    label: t('states.tasmania', { ns: 'home' }),
    value: 'Tas',
  },
  {
    label: t('states.australianCapitalTerritory', { ns: 'home' }),
    value: 'ACT',
  },
  {
    label: t('states.northernTerritory', { ns: 'home' }),
    value: 'NT',
  },
])

const selectedState = ref('Australia')

const participationPercentage = ref<ParticipationPercentage | null>(null)
const participationGraph = ref<ParticipationGraph | null>(null)

const percentageLoading = ref(false)
const graphLoading = ref(false)

const percentageError = ref('')
const graphError = ref('')

async function loadParticipationPercentage() {
  percentageLoading.value = true
  percentageError.value = ''

  try {
    participationPercentage.value = await getParticipationPercentage()
  } catch (error) {
    console.error(error)
    percentageError.value = t('errors.percentage', { ns: 'home' })
  } finally {
    percentageLoading.value = false
  }
}

async function loadParticipationGraph() {
  graphLoading.value = true
  graphError.value = ''

  try {
    participationGraph.value = await getParticipationGraph(selectedState.value)
  } catch (error) {
    console.error(error)
    graphError.value = t('errors.graph', { ns: 'home' })
    participationGraph.value = null
  } finally {
    graphLoading.value = false
  }
}

onMounted(() => {
  loadParticipationPercentage()
  loadParticipationGraph()
})

watch(selectedState, () => {
  loadParticipationGraph()
})

const hoveredPoint = ref<number | null>(null)

// Headline percentage
const headlinePercent = computed(() => {
  return participationPercentage.value?.percent ?? null
})

// const headlinePeriod = computed(() => {
//   if (!participationPercentage.value) {
//     return '—'
//   }

//   return participationPercentage.value.label
// })

// The API returns points oldest-first, each with a ready-made period label
// (e.g. "2018-2022") for the x-axis.
const chartPoints = computed(() => {
  if (!participationGraph.value) {
    return []
  }

  return participationGraph.value.points.map((point) => ({
    label: point.label,
    percent: point.percent,
  }))
})

const participationChange = computed(() => {
  const points = chartPoints.value

  if (points.length < 2) {
    return null
  }

  return points[points.length - 1].percent - points[0].percent
})

//Convert the three data points into SVG coordinates.
const svgChartPoints = computed(() => {
  const points = chartPoints.value

  if (points.length === 0) {
    return []
  }

  const width = 520
  const chartTop = 15
  const chartBottom = 180
  const chartHeight = chartBottom - chartTop

  const minPercent = 70
  const maxPercent = 85

  return points.map((point, index) => {
    const x = points.length === 1 ? 300 : 40 + (index / (points.length - 1)) * width

    const y = chartBottom - ((point.percent - minPercent) / (maxPercent - minPercent)) * chartHeight

    return {
      x,
      y,
      label: point.label,
      percent: point.percent,
    }
  })
})

// SVG line path.
const chartLinePath = computed(() => {
  return svgChartPoints.value
    .map((point, index) => {
      return `${index === 0 ? 'M' : 'L'} ${point.x} ${point.y}`
    })
    .join(' ')
})

//SVG filled area underneath the line.
const chartAreaPath = computed(() => {
  const points = svgChartPoints.value

  if (points.length === 0) {
    return ''
  }

  const line = points
    .map((point, index) => {
      return `${index === 0 ? 'M' : 'L'} ${point.x} ${point.y}`
    })
    .join(' ')

  const lastPoint = points[points.length - 1]
  const firstPoint = points[0]

  return `${line} L ${lastPoint.x} 180 L ${firstPoint.x} 180 Z`
})

//Range shown in the chart header.
const chartPeriodRange = computed(() => {
  const points = participationGraph.value?.points

  if (!points || points.length === 0) {
    return '—'
  }

  const firstYear = Math.min(...points.map((point) => point.year_start))

  const lastYear = Math.max(...points.map((point) => point.year_end))

  return `${firstYear} — ${lastYear}`
})

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
