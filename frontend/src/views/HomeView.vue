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
          <RouterLink to="/gprunner" class="button button-primary" @click="closeMenu"
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
          <h2>Progress is<br /><em>possible.</em></h2>
        </div>
        <div class="stats-filters">
          <label
            >State<select v-model="selectedState">
              <option v-for="state in states" :key="state" :value="state">{{ state }}</option>
            </select></label
          >
        </div>
      </div>
      <div class="stats-layout">
        <div class="big-stat">
          <template v-if="loadingStats"> — </template>

          <template v-else-if="latestScreeningRate !== null">
            {{ latestScreeningRate }}<span>%</span>
          </template>

          <template v-else> — </template>

          <p>of cervical cancer cases are linked to HPV.</p>
          <div class="stat-rule"></div>
          <small>World Health Organization</small>
        </div>
        <div class="chart-card">
          <div class="chart-top">
            <h3>Prevention impact</h3>
            <span>{{ chartPeriodRange }}</span>
          </div>
          <svg
            viewBox="0 0 560 220"
            role="img"
            aria-label="Line chart showing cervical screening participation over time"
          >
            <path class="grid-line" d="M0 180H560M0 125H560M0 70H560M0 15H560" />

            <path class="chart-area" :d="chartAreaPath" />

            <path class="chart-line" :d="chartLinePath" />

            <circle
              v-if="chartPoints.length"
              :cx="chartPoints[chartPoints.length - 1].x"
              :cy="chartPoints[chartPoints.length - 1].y"
              r="6"
              class="chart-dot"
            />
          </svg>
          <div class="chart-labels">
            <span v-for="stat in chartStats" :key="stat.reporting_period">
              {{ stat.reporting_period }}
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
import { getCervicalScreeningStats, type ScreeningStats } from '../api/stats'

const states = [
  'All states',
  'Victoria',
  'New South Wales',
  'Queensland',
  'Western Australia',
  'South Australia',
  'Tasmania',
]

const selectedState = ref(states[0])

const screeningStats = ref<ScreeningStats[]>([])
const loadingStats = ref(false)
const statsError = ref('')

async function loadScreeningStats() {
  loadingStats.value = true
  statsError.value = ''

  try {
    const state = selectedState.value === 'All states' ? undefined : selectedState.value

    screeningStats.value = await getCervicalScreeningStats(state)
  } catch (error) {
    console.error(error)
    statsError.value = 'Unable to load screening statistics.'
    screeningStats.value = []
  } finally {
    loadingStats.value = false
  }
}

onMounted(() => {
  loadScreeningStats()
})

watch(selectedState, () => {
  loadScreeningStats()
})

const latestScreeningRate = computed(() => {
  if (screeningStats.value.length === 0) {
    return null
  }

  const latest = screeningStats.value[screeningStats.value.length - 1]

  return latest.as_rate
})

const chartStats = computed(() => {
  return screeningStats.value.slice(-4)
})

const chartPoints = computed(() => {
  const stats = chartStats.value

  if (stats.length === 0) {
    return []
  }

  const width = 560
  const height = 165

  const rates = stats.map((stat) => stat.as_rate ?? 0)

  const minRate = Math.min(...rates)
  const maxRate = Math.max(...rates)

  const range = maxRate - minRate || 1

  return stats.map((stat, index) => {
    const x = stats.length === 1 ? width / 2 : (index / (stats.length - 1)) * width

    const y = height - (((stat.as_rate ?? 0) - minRate) / range) * height

    return {
      x,
      y,
      rate: stat.as_rate,
      period: stat.reporting_period,
    }
  })
})

const chartLinePath = computed(() => {
  if (chartPoints.value.length === 0) {
    return ''
  }

  return chartPoints.value
    .map((point, index) => {
      return `${index === 0 ? 'M' : 'L'}${point.x} ${point.y}`
    })
    .join(' ')
})

const chartAreaPath = computed(() => {
  if (chartPoints.value.length === 0) {
    return ''
  }

  const points = chartPoints.value

  const line = points
    .map((point, index) => {
      return `${index === 0 ? 'M' : 'L'}${point.x} ${point.y}`
    })
    .join(' ')

  return `${line} L${points[points.length - 1].x} 180 L${points[0].x} 180 Z`
})

const chartPeriodRange = computed(() => {
  if (chartStats.value.length === 0) {
    return '—'
  }

  const periods = chartStats.value.map(stat => stat.reporting_period)

  const startYears = periods.map(period =>
    Number(period.split('-')[0])
  )

  const endYears = periods.map(period =>
    Number(period.split('-')[1])
  )

  const startYear = Math.min(...startYears)
  const endYear = Math.max(...endYears)

  return `${startYear} — ${endYear}`
})
</script>
