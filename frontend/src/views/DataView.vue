<template>
  <main class="content-page data-page">
    <!-- <div class="page-breadcrumb">
      <RouterLink to="/">{{ t('common:header.home') }}</RouterLink
      ><span>/</span>{{ t('title', { ns: 'data' }) }}
    </div> -->
    <header class="page-heading">
      <p class="section-label">{{ t('eyebrow', { ns: 'data' }) }}</p>
      <h1>
        {{ t('heading', { ns: 'data' }) }} <em>{{ t('headingEmphasis', { ns: 'data' }) }}</em>
      </h1>
      <p>{{ t('intro', { ns: 'data' }) }}</p>
    </header>

    <section class="data-overview">
      <div class="data-stat">
        <p class="section-label">{{ t('participation.label', { ns: 'data' }) }}</p>
        <strong>{{ headlinePercent }}<span class="data-percent">%</span></strong>
        <p>{{ t('participation.description', { ns: 'data' }) }}</p>
        <small>{{ t('participation.period', { ns: 'data' }) }}</small>
      </div>
      <div class="data-chart-card">
        <div class="data-chart-heading">
          <h2>{{ t('chart.title', { ns: 'data' }) }}</h2>
          <span>{{ t('chart.range', { ns: 'data' }) }}</span>
        </div>

        <div class="data-line-chart">
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

          <div v-if="participationChange !== null" class="data-trend">
            <span>↓</span>
            {{ Math.abs(participationChange).toFixed(1) }}%
            {{ t('stats.participationRate', { ns: 'home' }) }}
          </div>

          <svg
            viewBox="0 0 600 220"
            role="img"
            :aria-label="t('chart.ariaLabel', { ns: 'data' })"
            class="data-chart-svg"
          >
            <!-- Y-axis -->
            <line x1="40" y1="15" x2="40" y2="180" class="data-chart-axis" />

            <!-- X-axis -->
            <line x1="40" y1="180" x2="560" y2="180" class="data-chart-axis" />

            <!-- Y-axis labels -->
            <text
              x="32"
              y="15"
              text-anchor="end"
              dominant-baseline="middle"
              class="data-chart-axis-label"
            >
              100%
            </text>

            <text
              x="32"
              y="180"
              text-anchor="end"
              dominant-baseline="middle"
              class="data-chart-axis-label"
            >
              0%
            </text>

            <!-- Grid lines -->
            <path class="data-chart-grid-line" d="M40 15H560M40 180H560" />

            <!-- Chart area -->
            <path
              v-if="!graphLoading && svgChartPoints.length"
              class="data-chart-area"
              :d="chartAreaPath"
            />

            <!-- Chart line -->
            <path
              v-if="!graphLoading && svgChartPoints.length"
              class="data-chart-line"
              :d="chartLinePath"
            />

            <!-- Invisible hover areas -->
            <circle
              v-for="(point, index) in svgChartPoints"
              :key="`hit-${point.label}`"
              :cx="point.x"
              :cy="point.y"
              r="18"
              fill="transparent"
              class="data-chart-hit-area"
              @mouseenter="hoveredPoint = index"
              @mouseleave="hoveredPoint = null"
            />

            <!-- Data points -->
            <circle
              v-for="point in svgChartPoints"
              :key="`${point.label}-${point.percent}`"
              :cx="point.x"
              :cy="point.y"
              r="5"
              class="data-chart-dot"
            />

            <!-- Tooltip -->
            <g v-if="hoveredPoint !== null" class="data-chart-tooltip">
              <line
                :x1="svgChartPoints[hoveredPoint].x"
                :x2="svgChartPoints[hoveredPoint].x"
                :y1="svgChartPoints[hoveredPoint].y"
                y2="180"
                class="data-chart-hover-line"
              />

              <rect
                :x="svgChartPoints[hoveredPoint].x - 48"
                :y="svgChartPoints[hoveredPoint].y - 48"
                width="96"
                height="36"
                rx="6"
                class="data-chart-tooltip-box"
              />

              <text
                :x="svgChartPoints[hoveredPoint].x"
                :y="svgChartPoints[hoveredPoint].y - 30"
                text-anchor="middle"
                dominant-baseline="middle"
                class="data-chart-tooltip-text"
              >
                {{ svgChartPoints[hoveredPoint].percent }}%
              </text>
            </g>
          </svg>

          <!-- X-axis labels -->
          <div class="data-chart-labels">
            <span v-for="point in svgChartPoints" :key="point.label">
              {{ point.label }}
            </span>
          </div>
        </div>
      </div>
    </section>

    <section class="age-section">
      <p class="section-label">{{ t('ageGroups.label', { ns: 'data' }) }}</p>
      <h2>{{ t('ageGroups.title', { ns: 'data' }) }}</h2>
      <div class="age-bars">
        <div v-for="group in ageGroups" :key="group.label" class="age-bar-group">
          <strong>{{ group.value }}%</strong
          ><span class="age-bar" :style="{ height: `${group.value * 1.55}px` }"></span
          ><small>{{ group.label }}</small>
        </div>
      </div>
      <aside class="data-note">{{ t('ageGroups.note', { ns: 'data' }) }}</aside>
    </section>
    <footer class="data-source">
      <strong>{{ t('sources.title', { ns: 'data' }) }}</strong>
      <p>{{ t('sources.description', { ns: 'data' }) }}</p>
    </footer>
  </main>
</template>

<script setup lang="ts">
import { useTranslation } from '../i18n/useTranslation'
import '../assets/contentPages.css'
import { computed, onMounted, ref, watch } from 'vue'

import {
  getParticipationGraph,
  getParticipationPercentage,
  type ParticipationGraph,
  type ParticipationPercentage,
} from '../api/stats'

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

// Fake age group demo
const ageGroups = [
  { label: '25–34', value: 71 },
  { label: '35–44', value: 76 },
  { label: '45–54', value: 81 },
  { label: '55–64', value: 79 },
  { label: '65–74', value: 68 },
]

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
</script>
