<template>
  <main>
    <section class="hero-section" id="top">
      <div class="hero-copy">
        <p class="eyebrow"><span class="eyebrow-dot"></span> Prevention is powerful</p>
        <h1>Your health<br /><em>deserves a voice.</em></h1>
        <p class="hero-text">
          No matter your culture, language, or background, you deserve to feel informed and
          confident about cervical screening. Cervical cancer is preventable—take a simple step
          today to protect your future.
        </p>
        <div class="hero-actions">
          <RouterLink to="/gprunner" class="button button-primary"
            >Start learning <span>↗</span></RouterLink
          >
          <a href="#stats" class="text-link">See the numbers <span>↓</span></a>
        </div>
      </div>
      <div class="hero-art" aria-label="Abstract illustration of a flower and sun">
        <div class="sun"></div>
        <div class="art-orbit orbit-one"></div>
        <div class="art-orbit orbit-two"></div>
        <div class="stem"></div>
        <div class="leaf leaf-left"></div>
        <div class="leaf leaf-right"></div>
        <div class="flower"><i></i><i></i><i></i><i></i><i></i></div>
        <div class="art-note note-one">Know your<br /><strong>options</strong></div>
        <div class="art-note note-two">Small steps<br /><strong>matter</strong></div>
      </div>
    </section>

    <section class="intro-section" id="learn">
      <div class="section-label">01 / The essentials</div>
      <div class="intro-grid">
        <h2>A little knowledge<br /><em>goes a long way.</em></h2>
        <div>
          <p class="lead">
            Cervical cancer starts in the cervix, but with regular screening and HPV vaccination, it
            can often be prevented before it starts.
          </p>
          <a class="arrow-link" href="#screening-info">Frequently Asked Question <span>→</span></a>
        </div>
      </div>
      <div class="steps-grid" id="steps">
        <article class="step-card">
          <span class="step-number">01</span>
          <div class="step-icon icon-shield">♡</div>
          <h3>HPV vaccination</h3>
          <p>
            HPV (human papillomavirus) is a common virus that can cause cervical cancer. Vaccination
            helps prevent HPV infection.
          </p>
        </article>
        <article class="step-card featured">
          <span class="step-number">02</span>
          <div class="step-icon">◌</div>
          <h3>Regular screening</h3>
          <p>Finds cell changes early, when they are easier to treat and manage.</p>
        </article>
        <article class="step-card">
          <span class="step-number">03</span>
          <div class="step-icon">✦</div>
          <h3>Know your body</h3>
          <p>Talk to a healthcare professional about anything that feels unusual.</p>
        </article>
      </div>
    </section>

    <section class="screening-info" id="screening-info">
      <div class="section-label">02 / The screening basics</div>
      <div class="screening-info-heading">
        <h2>Clear answers for<br /><em>your next step.</em></h2>
        <p>
          Knowing what to expect can make screening feel simpler. Here is the information to help
          you feel informed and supported.
        </p>
      </div>
      <div class="info-grid">
        <article class="info-card">
          <span class="info-index">01</span>
          <h3>What is cervical screening?</h3>
          <p>
            A quick health check for high-risk HPV and early cell changes in the cervix. Finding
            changes early helps prevent cervical cancer.
          </p>
        </article>
        <article class="info-card">
          <span class="info-index">02</span>
          <h3>Why is it important?</h3>
          <p>
            Screening can find HPV and early cell changes before they become cancer. It is one of
            the best ways to protect your future health.
          </p>
        </article>
        <article class="info-card">
          <span class="info-index">03</span>
          <h3>Who is it for?</h3>
          <p>
            In Australia, cervical screening is recommended for people aged 25 to 74 who have a
            cervix, whether or not they have had the HPV vaccine.
          </p>
        </article>
        <article class="info-card">
          <span class="info-index">04</span>
          <h3>How often?</h3>
          <p>
            Most people need screening every five years. Your healthcare provider may recommend a
            different plan based on your result or health history.
          </p>
        </article>
        <article class="info-card">
          <span class="info-index">05</span>
          <h3>What happens?</h3>
          <p>
            A small sample is collected from the cervix by a trained healthcare professional. It
            usually takes a few minutes, and you can ask questions at any time.
          </p>
        </article>
        <article class="info-card info-card-accent">
          <span class="info-index">06</span>
          <h3>Your screening options</h3>
          <p>
            Choose a healthcare provider for a clinician-collected test, or ask if self-collection
            is available for you. Both options check for HPV.
          </p>
          <!-- This section will be implemented when GP finder feature is ready (Iteration 2)
          <RouterLink to="/gpfinder" class="arrow-link"
            >Look for GP near you <span>→</span></RouterLink
          > -->
        </article>
      </div>
    </section>

    <section class="stats-section" id="stats">
      <div class="stats-heading">
        <div>
          <div class="section-label light">03 / The bigger picture</div>
          <h2>Every<br /><em>Screening counts.</em></h2>
        </div>
        <div class="stats-filters">
          <label>
            State
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

          <p>Every screening helps move Australia closer to eliminating cervical cancer.</p>

          <div class="stat-rule"></div>

          <small v-if="participationPercentage">
            {{ headlinePeriod }}
          </small>

          <small v-else> — </small>
        </div>
        <div class="chart-card">
          <div class="chart-top">
            <h3>Screening Participation Rate</h3>
            <span>{{ chartPeriodRange }}</span>
          </div>

          <div v-if="participationChange !== null" class="trend-indicator">
            <span>↓</span>
            {{ Math.abs(participationChange).toFixed(1) }} % participation rate
          </div>

          <svg
            viewBox="0 0 600 220"
            role="img"
            aria-label="Line chart showing cervical screening participation over time"
          >
            <!-- Grid lines -->
            <path
              class="grid-line"
              d="M40 15H560M40 56.25H560M40 97.5H560M40 138.75H560M40 180H560"
            />

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

    <!-- This section will be implemented when GP finder feature is ready (Iteration 2)
    <section class="closing-section">
      <div class="closing-bloom"></div>
      <div class="section-label">04 / Your next step</div>
      <h2>Care for yourself.<br /><em>Share what you know.</em></h2>
      <p>Every conversation can help someone take their next step toward prevention.</p>
      <RouterLink to="/gpfinder" class="button button-primary"
        >Check your nearest GP <span>↗</span></RouterLink
      >
    </section>
    -->
  </main>
</template>

<script setup lang="ts">
import '../assets/homeView.css'

import { computed, onMounted, ref, watch } from 'vue'

import {
  getParticipationGraph,
  getParticipationPercentage,
  type ParticipationGraph,
  type ParticipationPercentage,
} from '../api/stats'

const states = [
  { label: 'All states', value: 'Australia' },
  { label: 'Victoria', value: 'Vic' },
  { label: 'New South Wales', value: 'NSW' },
  { label: 'Queensland', value: 'Qld' },
  { label: 'Western Australia', value: 'WA' },
  { label: 'South Australia', value: 'SA' },
  { label: 'Tasmania', value: 'Tas' },
  { label: 'Australian Capital Territory', value: 'ACT' },
  { label: 'Northern Territory', value: 'NT' },
]

const selectedState = ref(states[0].value)

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
    percentageError.value = 'Unable to load participation percentage.'
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
    graphError.value = 'Unable to load participation graph.'
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
