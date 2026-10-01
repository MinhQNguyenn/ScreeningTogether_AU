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
          <a href="#learn" class="button button-primary">{{
            t('hero.startLearning', { ns: 'home' })
          }}</a>
          <!-- <a href="#stats" class="text-link"
            >{{ t('hero.seeNumbers', { ns: 'home' }) }}<span>↓</span></a
          > -->
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
        <div class="art-note note-one">
          {{ t('hero.noteOne', { ns: 'home' }) }}<br /><strong>{{
            t('hero.noteOneStrong', { ns: 'home' })
          }}</strong>
        </div>
        <div class="art-note note-two">
          {{ t('hero.noteTwo', { ns: 'home' }) }}<br /><strong>{{
            t('hero.noteTwoStrong', { ns: 'home' })
          }}</strong>
        </div>
      </div>
    </section>

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
          <p>{{ t('essentials.steps.body.description', { ns: 'home' }) }}</p>
        </article>
      </div>
    </section>

    <section class="screening-info" id="screening-info">
      <div class="section-label">{{ t('screening.label', { ns: 'home' }) }}</div>
      <div class="screening-info-heading">
        <h2>
          {{ t('screening.title', { ns: 'home' }) }}<br /><em>{{
            t('screening.titleEmphasis', { ns: 'home' })
          }}</em>
        </h2>
        <p>
          {{ t('screening.description', { ns: 'home' }) }}
        </p>
      </div>
      <div class="info-grid">
        <article class="info-card">
          <div class="info-card-inner">
            <div class="info-card-front">
              <span class="info-index">01</span>
              <h3>{{ t('screening.cards.what.title', { ns: 'home' }) }}</h3>
            </div>
            <div class="info-card-back">
              <p>
                {{ t('screening.cards.what.description', { ns: 'home' }) }}
              </p>
            </div>
          </div>
        </article>

        <article class="info-card">
          <div class="info-card-inner">
            <div class="info-card-front">
              <span class="info-index">02</span>
              <h3>{{ t('screening.cards.why.title', { ns: 'home' }) }}</h3>
            </div>
            <div class="info-card-back">
              <p>
                {{ t('screening.cards.why.description', { ns: 'home' }) }}
              </p>
            </div>
          </div>
        </article>

        <article class="info-card">
          <div class="info-card-inner">
            <div class="info-card-front">
              <span class="info-index">03</span>
              <h3>{{ t('screening.cards.who.title', { ns: 'home' }) }}</h3>
            </div>
            <div class="info-card-back">
              <p>
                {{ t('screening.cards.who.description', { ns: 'home' }) }}
              </p>
              <a href="#stats" class="arrow-link">
                {{ t('screening.cards.options.theNumber', { ns: 'home' }) }} <span>→</span>
              </a>
            </div>
          </div>
        </article>

        <article class="info-card">
          <div class="info-card-inner">
            <div class="info-card-front">
              <span class="info-index">04</span>
              <h3>{{ t('screening.cards.howOften.title', { ns: 'home' }) }}</h3>
            </div>
            <div class="info-card-back">
              <p>
                {{ t('screening.cards.howOften.description', { ns: 'home' }) }}
              </p>
            </div>
          </div>
        </article>

        <article class="info-card">
          <div class="info-card-inner">
            <div class="info-card-front">
              <span class="info-index">05</span>
              <h3>{{ t('screening.cards.whatHappens.title', { ns: 'home' }) }}</h3>
            </div>
            <div class="info-card-back">
              <p>
                {{ t('screening.cards.whatHappens.description', { ns: 'home' }) }}
              </p>
            </div>
          </div>
        </article>

        <article class="info-card info-card-accent">
          <div class="info-card-inner">
            <div class="info-card-front">
              <span class="info-index">06</span>
              <h3>{{ t('screening.cards.options.title', { ns: 'home' }) }}</h3>
            </div>

            <div class="info-card-back">
              <p>
                {{ t('screening.cards.options.description', { ns: 'home' }) }}
              </p>

              <RouterLink to="/iteration2/gpfinder" class="arrow-link">
                {{ t('screening.cards.options.findGp', { ns: 'home' }) }} <span>→</span>
              </RouterLink>
            </div>
          </div>
        </article>
      </div>
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
        <div class="stats-filters">
          <label>
            {{ t('stats.state', { ns: 'home' }) }}
            <select v-model="selectedState">
              <option v-for="state in states" :key="state.value" :value="state.value">
                {{ state.label }}
              </option>
            </select>
          </label>
        </div>
      </div>
      <div class="stats-layout">
        <div class="big-stat">
          <strong v-if="percentageLoading"> — </strong>

          <strong v-else-if="headlinePercent !== null">
            {{ headlinePercent }}<span>%</span>
          </strong>

          <strong v-else> — </strong>

          <p>{{ t('stats.eligibleWomen', { ns: 'home' }) }}</p>

          <div class="stat-rule"></div>

          <small v-if="participationPercentage">
            {{ t('stats.period', { ns: 'home' }) }}
          </small>

          <small v-else> — </small>
        </div>
        <div class="chart-card">
          <div class="chart-top">
            <h3>{{ t('stats.chartTitle', { ns: 'home' }) }}</h3>
            <span>{{ chartPeriodRange }}</span>
          </div>

          <div v-if="participationChange !== null" class="trend-indicator">
            <span>↓</span>
            {{ Math.abs(participationChange).toFixed(1) }}%
            {{ t('stats.participationRate', { ns: 'home' }) }}
          </div>
          <svg
            viewBox="0 0 600 220"
            role="img"
            :aria-label="t('stats.chartAriaLabel', { ns: 'home' })"
          >
            <!-- Y-axis -->
            <line x1="40" y1="15" x2="40" y2="180" class="chart-axis" />

            <!-- X-axis -->
            <line x1="40" y1="180" x2="560" y2="180" class="chart-axis" />

            <!-- Y-axis labels -->
            <text
              x="32"
              y="15"
              text-anchor="end"
              dominant-baseline="middle"
              class="chart-axis-label"
            >
              100%
            </text>

            <text
              x="32"
              y="180"
              text-anchor="end"
              dominant-baseline="middle"
              class="chart-axis-label"
            >
              0%
            </text>

            <!-- Grid lines -->
            <path class="grid-line" d="M40 15H560M40 180H560" />

            <!-- Chart -->
            <path
              v-if="!graphLoading && svgChartPoints.length"
              class="chart-area"
              :d="chartAreaPath"
            />

            <path
              v-if="!graphLoading && svgChartPoints.length"
              class="chart-line"
              :d="chartLinePath"
            />

            <!-- Data points -->
            <circle
              v-for="(point, index) in svgChartPoints"
              :key="`hit-${point.label}`"
              :cx="point.x"
              :cy="point.y"
              r="18"
              fill="transparent"
              class="chart-hit-area"
              @mouseenter="hoveredPoint = index"
              @mouseleave="hoveredPoint = null"
            />

            <circle
              v-for="point in svgChartPoints"
              :key="`${point.label}-${point.percent}`"
              :cx="point.x"
              :cy="point.y"
              r="5"
              class="chart-dot"
            />

            <!-- Tooltip -->
            <g v-if="hoveredPoint !== null" class="chart-tooltip">
              <line
                :x1="svgChartPoints[hoveredPoint].x"
                :x2="svgChartPoints[hoveredPoint].x"
                :y1="svgChartPoints[hoveredPoint].y"
                y2="180"
                class="chart-hover-line"
              />

              <rect
                :x="svgChartPoints[hoveredPoint].x - 48"
                :y="svgChartPoints[hoveredPoint].y - 48"
                width="96"
                height="36"
                rx="6"
                class="chart-tooltip-box"
              />

              <text
                :x="svgChartPoints[hoveredPoint].x"
                :y="svgChartPoints[hoveredPoint].y - 30"
                text-anchor="middle"
                dominant-baseline="middle"
                class="chart-tooltip-text"
              >
                {{ svgChartPoints[hoveredPoint].percent }}%
              </text>
            </g>
          </svg>

          <div class="chart-labels">
            <span v-for="point in chartPoints" :key="`${point.label}-${point.percent}`">
              {{ point.label }}
            </span>
          </div>
        </div>
      </div>
    </section>

    <section class="closing-section">
      <div class="closing-bloom"></div>
      <div class="section-label">{{ t('closing.label', { ns: 'home' }) }}</div>
      <h2>
        {{ t('closing.title', { ns: 'home' }) }}<br /><em>{{
          t('closing.titleEmphasis', { ns: 'home' })
        }}</em>
      </h2>
      <p>{{ t('closing.description', { ns: 'home' }) }}</p>
      <RouterLink to="/iteration2/gpfinder" class="button button-primary">{{
        t('closing.checkGp', { ns: 'home' })
      }}</RouterLink>
    </section>
  </main>
</template>

<script setup lang="ts">
import '../../assets/iteration2/homeView.css'

import { computed, onMounted, ref, watch } from 'vue'

import {
  getParticipationGraph,
  getParticipationPercentage,
  type ParticipationGraph,
  type ParticipationPercentage,
} from '../../api/stats'

import { useTranslation } from '../../i18n/useTranslation'
const { t } = useTranslation()

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

const headlinePeriod = computed(() => {
  if (!participationPercentage.value) {
    return '—'
  }

  return participationPercentage.value.label
})

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
</script>
