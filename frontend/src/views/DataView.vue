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

    <section class="data-section">
      <div class="section-index">
        <span class="num">01 / {{ SECTION_TOTAL }}</span>
        <span class="kicker">{{ t('participation.label', { ns: 'data' }) }}</span>
      </div>

      <div class="data-overview">
        <div class="data-stat">
          <strong>{{ headlinePercent }}<span class="data-percent">%</span></strong>
          <p>{{ t('participation.description', { ns: 'data' }) }}</p>
          <small>{{ headlinePeriod }}</small>
        </div>
        <div class="data-chart-card">
          <div class="data-chart-heading">
            <h2>{{ t('chart.title', { ns: 'data' }) }}</h2>
            <span>{{ chartRange }}</span>
          </div>

          <div class="data-line-chart">
            <div class="stats-filters">
              <label>
                {{ t('stateLabel', { ns: 'data' }) }}
                <select v-model="selectedState">
                  <option v-for="state in states" :key="state.value" :value="state.value">
                    {{ state.label }}
                  </option>
                </select>
              </label>
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

              <!-- Grid lines + y-axis labels (labels match the zoomed scale) -->
              <g v-for="tick in trendTicks" :key="tick.value">
                <path class="data-chart-grid-line" :d="`M40 ${tick.y}H560`" />
                <text
                  x="32"
                  :y="tick.y"
                  text-anchor="end"
                  dominant-baseline="middle"
                  class="data-chart-axis-label"
                >
                  {{ tick.value }}%
                </text>
              </g>

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
          <p v-if="trendCaption" class="data-caption">{{ trendCaption }}</p>
          <p class="data-caveat">
            {{ t('chart.axisNote', { ns: 'data', min: trendScale.min }) }}
            {{
              selectedState === 'Australia'
                ? t('chart.caveatWindows', { ns: 'data' })
                : t('chart.caveatStates', { ns: 'data' })
            }}
          </p>
        </div>
      </div>
    </section>

    <section class="data-section alt">
      <div class="section-index">
        <span class="num">02 / {{ SECTION_TOTAL }}</span>
        <span class="kicker">{{ t('ageGroups.label', { ns: 'data' }) }}</span>
      </div>
      <h2 class="section-title">{{ t('ageGroups.title', { ns: 'data' }) }}</h2>
      <div class="data-chart-card">
        <div class="stats-filters">
          <label>
            {{ t('windowLabel', { ns: 'data' }) }}
            <select v-model="selectedAgeWindow">
              <option v-for="w in ageData?.windows ?? []" :key="w" :value="w">{{ w }}</option>
            </select>
          </label>
        </div>

        <!-- the age chart follows the state picked above, so say which one it shows -->
        <p class="data-caveat">
          {{ t('ageGroups.showing', { ns: 'data', place: selectedStateLabel }) }}
        </p>

        <p v-if="ageError" class="data-caveat">{{ t('dataNotAvailable', { ns: 'data' }) }}</p>
        <template v-else-if="ageData">
          <div class="data-bars" role="img" :aria-label="t('ageGroups.title', { ns: 'data' })">
            <div
              v-for="(point, index) in ageData.points"
              :key="point.age_group"
              class="data-bar-group"
              tabindex="0"
              :aria-label="`${point.age_group}: ${point.percent}%`"
            >
              <span class="data-bar-tip">{{ point.age_group }} · {{ point.percent }}%</span>
              <strong>{{ Math.round(point.percent) }}%</strong>
              <span class="data-bar" :style="{ height: `${point.percent * 1.8}px` }"></span>
            </div>
          </div>
          <div class="data-bar-axis">
            <small v-for="point in ageData.points" :key="point.age_group">{{
              point.age_group
            }}</small>
          </div>
          <p class="data-caption">
            {{
              t('ageGroups.caption', {
                ns: 'data',
                window: ageData.window,
                lowestPercent: ageData.lowest_percent.toFixed(1),
                lowestAge: ageData.lowest_age_group,
                highestPercent: ageData.highest_percent.toFixed(1),
                highestAge: ageData.highest_age_group,
              })
            }}
          </p>
        </template>
      </div>
      <aside class="why-varies">
        <svg class="icon" width="18" height="18" viewBox="0 0 24 24" aria-hidden="true">
          <circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2" />
          <path
            d="M12 11v6M12 7.5v.5"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
          />
        </svg>
        <p class="text">
          <b>{{ t('whyVaries', { ns: 'data' }) }}</b>
          {{ t('ageGroups.note', { ns: 'data' }) }}
        </p>
      </aside>

      <!-- verified quote: AIHW, NCSP monitoring report 2025, Performance Indicator 1 -->
      <blockquote class="data-quote">
        <p>“{{ t('ageGroups.quote', { ns: 'data' }) }}”</p>
        <footer>
          {{ t('ageGroups.quoteSource', { ns: 'data' }) }} ·
          <a
            href="https://www.aihw.gov.au/reports/cancer-screening/ncsp-monitoring-report-2025/contents/recruitment/pi-1-participation"
            target="_blank"
            rel="noopener"
            >{{ t('learnMore', { ns: 'data' }) }}</a
          >
        </footer>
      </blockquote>
    </section>

    <section class="data-section">
      <div class="section-index">
        <span class="num">03 / {{ SECTION_TOTAL }}</span>
        <span class="kicker">{{ t('selfCollection.label', { ns: 'data' }) }}</span>
      </div>

      <div class="data-overview">
        <div class="data-stat">
          <strong>{{ selfHeadline }}</strong>
          <p v-if="selfLatestYear">
            {{
              t('selfCollection.description', {
                ns: 'data',
                year: selfLatestYear.year,
                share: selfLatestYear.self_collected_percent?.toFixed(0),
              })
            }}
          </p>
          <blockquote class="data-quote">
            <p>“{{ t('selfCollection.accuracy', { ns: 'data' }) }}”</p>
            <footer>
              {{ t('selfCollection.accuracySource', { ns: 'data' }) }} ·
              <a
                href="https://www.health.qld.gov.au/newsroom/news/screening-for-the-cause-of-almost-all-cervical-cancer-can-now-be-in-your-hands-thanks-to-the-new-self-collection-option"
                target="_blank"
                rel="noopener"
                >{{ t('learnMore', { ns: 'data' }) }}</a
              >
            </footer>
          </blockquote>
        </div>

        <div class="data-chart-card">
          <div class="data-chart-heading">
            <h2>{{ t('selfCollection.title', { ns: 'data' }) }}</h2>
            <div class="data-toggle" role="group">
              <button
                type="button"
                :aria-pressed="selfMode === 'count'"
                @click="selfMode = 'count'"
              >
                {{ t('selfCollection.modeCount', { ns: 'data' }) }}
              </button>
              <button
                type="button"
                :aria-pressed="selfMode === 'share'"
                @click="selfMode = 'share'"
              >
                {{ t('selfCollection.modeShare', { ns: 'data' }) }}
              </button>
            </div>
          </div>

          <p v-if="selfError" class="data-caveat">{{ t('dataNotAvailable', { ns: 'data' }) }}</p>
          <div v-else-if="selfPoints.length" class="data-line-chart">
            <svg
              viewBox="0 0 600 220"
              role="img"
              :aria-label="t('selfCollection.title', { ns: 'data' })"
              class="data-chart-svg"
            >
              <!-- grid + y labels -->
              <g v-for="tick in selfTicks" :key="tick.value">
                <path class="data-chart-grid-line" :d="`M40 ${tick.y}H560`" />
                <text
                  x="32"
                  :y="tick.y"
                  text-anchor="end"
                  dominant-baseline="middle"
                  class="data-chart-axis-label"
                >
                  {{ tick.label }}
                </text>
              </g>
              <line x1="40" y1="15" x2="40" y2="180" class="data-chart-axis" />
              <line x1="40" y1="180" x2="560" y2="180" class="data-chart-axis" />

              <!-- July 2022: self-collection opened to everyone eligible (AIHW) -->
              <g v-if="july2022X !== null">
                <line
                  :x1="july2022X"
                  :x2="july2022X"
                  y1="15"
                  y2="180"
                  class="data-chart-hover-line"
                />
                <text :x="july2022X - 6" y="19" text-anchor="end" class="data-chart-axis-label">
                  {{ t('selfCollection.july2022', { ns: 'data' }) }}
                </text>
              </g>

              <path class="data-chart-area" :d="selfAreaPath" />
              <path class="data-chart-line" :d="selfLinePath" />

              <!-- year labels under each January -->
              <text
                v-for="p in selfPoints.filter((p) => p.month === 1)"
                :key="`y-${p.year}`"
                :x="p.x"
                y="196"
                class="data-chart-axis-label"
              >
                {{ p.year }}
              </text>

              <!-- hover strips, one per month -->
              <rect
                v-for="(p, index) in selfPoints"
                :key="`hit-${p.year}-${p.month}`"
                :x="p.x - selfStep / 2"
                y="15"
                :width="selfStep"
                height="165"
                class="data-chart-hit-area"
                @mouseenter="hoveredMonth = index"
                @mouseleave="hoveredMonth = null"
              />

              <g v-if="hoveredMonth !== null" class="data-chart-tooltip">
                <line
                  :x1="selfPoints[hoveredMonth].x"
                  :x2="selfPoints[hoveredMonth].x"
                  :y1="selfPoints[hoveredMonth].y"
                  y2="180"
                  class="data-chart-hover-line"
                />
                <circle
                  :cx="selfPoints[hoveredMonth].x"
                  :cy="selfPoints[hoveredMonth].y"
                  r="5"
                  class="data-chart-dot"
                />
                <rect
                  :x="selfTooltipX - 70"
                  :y="selfPoints[hoveredMonth].y - 48"
                  width="140"
                  height="36"
                  rx="6"
                  class="data-chart-tooltip-box"
                />
                <text
                  :x="selfTooltipX"
                  :y="selfPoints[hoveredMonth].y - 30"
                  text-anchor="middle"
                  dominant-baseline="middle"
                  class="data-chart-tooltip-text"
                >
                  {{ selfPoints[hoveredMonth].label }}
                </text>
              </g>
            </svg>
          </div>

          <p v-if="selfFirstYear" class="data-caption">
            {{
              t('selfCollection.caption', {
                ns: 'data',
                firstYear: selfFirstYear.year,
                firstCount: selfFirstYear.self_collected.toLocaleString(),
              })
            }}
            <template v-if="selfPartialYear">
              {{ t('selfCollection.partialYear', { ns: 'data', year: selfPartialYear.year }) }}
            </template>
          </p>
          <p class="data-caveat">{{ t('selfCollection.caveatTests', { ns: 'data' }) }}</p>
        </div>
      </div>
    </section>

    <section class="data-section alt">
      <div class="section-index">
        <span class="num">04 / {{ SECTION_TOTAL }}</span>
        <span class="kicker">{{ t('socioeconomic.label', { ns: 'data' }) }}</span>
      </div>
      <h2 class="section-title">{{ t('socioeconomic.title', { ns: 'data' }) }}</h2>
      <div class="data-chart-card">
        <div class="stats-filters">
          <label>
            {{ t('windowLabel', { ns: 'data' }) }}
            <select v-model="selectedSesWindow">
              <option v-for="w in sesData?.windows ?? []" :key="w" :value="w">{{ w }}</option>
            </select>
          </label>
        </div>

        <p v-if="sesError" class="data-caveat">{{ t('dataNotAvailable', { ns: 'data' }) }}</p>
        <template v-else-if="sesData">
          <div class="data-bars" role="img" :aria-label="t('socioeconomic.title', { ns: 'data' })">
            <div
              v-for="(point, index) in sesData.points"
              :key="point.quintile"
              class="data-bar-group"
              tabindex="0"
              :aria-label="`${quintileLabel(point.quintile)}: ${point.percent}%`"
            >
              <span class="data-bar-tip"
                >{{ quintileLabel(point.quintile) }} · {{ point.percent }}%</span
              >
              <strong>{{ Math.round(point.percent) }}%</strong>
              <span class="data-bar" :style="{ height: `${point.percent * 1.8}px` }"></span>
            </div>
          </div>
          <div class="data-bar-axis">
            <small v-for="point in sesData.points" :key="point.quintile">{{
              quintileLabel(point.quintile)
            }}</small>
          </div>
          <p class="data-caption">
            {{
              t('socioeconomic.caption', {
                ns: 'data',
                window: sesData.window,
                q1Percent: sesData.points[0].percent.toFixed(1),
                q5Percent: sesData.points[sesData.points.length - 1].percent.toFixed(1),
              })
            }}
          </p>
          <!-- how to read area data (ecological caveat) stays with the chart -->
          <p class="data-caveat">{{ t('socioeconomic.caveatArea', { ns: 'data' }) }}</p>
        </template>
      </div>

      <aside class="why-varies">
        <svg class="icon" width="18" height="18" viewBox="0 0 24 24" aria-hidden="true">
          <circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2" />
          <path
            d="M12 11v6M12 7.5v.5"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
          />
        </svg>
        <p class="text">
          <b>{{ t('whyVaries', { ns: 'data' }) }}</b>
          {{ t('socioeconomic.caveatStructural', { ns: 'data' }) }}
        </p>
      </aside>

      <!-- source: health.gov.au NCSP Healthcare Provider Toolkit (summarised, so no quotation marks) -->
      <blockquote class="data-quote">
        <p>{{ t('socioeconomic.quote', { ns: 'data' }) }}</p>
        <footer>
          {{ t('socioeconomic.quoteSource', { ns: 'data' }) }} ·
          <a
            href="https://www.health.gov.au/our-work/ncsp-healthcare-provider-toolkit/working-with-patients/economic-disadvantage"
            target="_blank"
            rel="noopener"
            >{{ t('learnMore', { ns: 'data' }) }}</a
          >
        </footer>
      </blockquote>
    </section>

    <section class="data-section map-section">
      <div class="section-index">
        <span class="num">05 / {{ SECTION_TOTAL }}</span>
        <span class="kicker">{{ t('mapKicker', { ns: 'data' }) }}</span>
      </div>
      <ChoroplethMap />
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
import ChoroplethMap from '../components/ChoroplethMap.vue'

import {
  getParticipationByAge,
  getParticipationBySocioeconomic,
  getParticipationGraph,
  getParticipationPercentage,
  getSelfCollection,
  type AgeParticipation,
  type ParticipationGraph,
  type ParticipationPercentage,
  type SelfCollection,
  type SocioeconomicParticipation,
} from '../api/stats'

const { t } = useTranslation()
const SECTION_TOTAL = '05'

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

const selectedStateLabel = computed(
  () => states.value.find((s) => s.value === selectedState.value)?.label ?? selectedState.value,
)

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

const ageData = ref<AgeParticipation | null>(null)
const ageError = ref(false)
const selectedAgeWindow = ref<string | undefined>(undefined) // undefined = latest window

async function loadAge() {
  ageError.value = false
  try {
    // follows the state picked in the participation chart
    ageData.value = await getParticipationByAge(selectedState.value, selectedAgeWindow.value)
    selectedAgeWindow.value = ageData.value.window
  } catch (error) {
    console.error(error)
    ageError.value = true
  }
}

const sesData = ref<SocioeconomicParticipation | null>(null)
const sesError = ref(false)
const selectedSesWindow = ref<string | undefined>(undefined)

async function loadSes() {
  sesError.value = false
  try {
    sesData.value = await getParticipationBySocioeconomic(selectedSesWindow.value)
    selectedSesWindow.value = sesData.value.window
  } catch (error) {
    console.error(error)
    sesError.value = true
  }
}

const selfData = ref<SelfCollection | null>(null)
const selfError = ref(false)
const selfMode = ref<'count' | 'share'>('count')
const hoveredMonth = ref<number | null>(null)

async function loadSelfCollection() {
  selfError.value = false
  try {
    selfData.value = await getSelfCollection()
  } catch (error) {
    console.error(error)
    selfError.value = true
  }
}

onMounted(() => {
  loadParticipationPercentage()
  loadParticipationGraph()
  loadAge()
  loadSes()
  loadSelfCollection()
})

watch(selectedState, () => {
  loadParticipationGraph()
  loadAge()
})

watch(selectedAgeWindow, (newWindow, oldWindow) => {
  if (oldWindow !== undefined && newWindow !== ageData.value?.window) loadAge()
})

watch(selectedSesWindow, (newWindow, oldWindow) => {
  if (oldWindow !== undefined && newWindow !== sesData.value?.window) loadSes()
})

const hoveredPoint = ref<number | null>(null)

// Headline percentage
const headlinePercent = computed(() => {
  return participationPercentage.value?.percent ?? null
})

// period from the data, e.g. "2020-2024"
const headlinePeriod = computed(() => {
  return participationPercentage.value?.label ?? '—'
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

// "2018–2024": first year of the first period to last year of the last period
const chartRange = computed(() => {
  const points = participationGraph.value?.points ?? []
  if (!points.length) return ''
  return `${points[0].year_start}–${points[points.length - 1].year_end}`
})

// approved caption, change in percentage points with a sign
const trendCaption = computed(() => {
  const points = chartPoints.value
  if (points.length < 2) return ''

  const first = points[0]
  const last = points[points.length - 1]
  const change = last.percent - first.percent
  const values = {
    ns: 'data',
    window: last.label,
    percent: last.percent.toFixed(1),
    firstWindow: first.label,
    firstPercent: first.percent.toFixed(1),
    change: `${change >= 0 ? '+' : '−'}${Math.abs(change).toFixed(1)}`,
  }

  if (selectedState.value === 'Australia') {
    return t('chart.caption', values)
  }
  return t('chart.captionState', { ...values, place: selectedStateLabel.value })
})

// Zoomed scale (70–85 by default) so the change is easier to see.
// The axis labels show the real values, and widen automatically if a state falls outside.
const trendScale = computed(() => {
  const values = chartPoints.value.map((p) => p.percent)
  const min = Math.min(70, ...values.map((v) => Math.floor(v / 5) * 5))
  const max = Math.max(85, ...values.map((v) => Math.ceil(v / 5) * 5))
  return { min, max }
})

const trendTicks = computed(() => {
  const { min, max } = trendScale.value
  const ticks = []
  for (let value = min; value <= max; value += 5) {
    ticks.push({ value, y: 180 - ((value - min) / (max - min)) * 165 })
  }
  return ticks
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

  const minPercent = trendScale.value.min
  const maxPercent = trendScale.value.max

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

// self-collection chart
const selfLatestYear = computed(() => {
  const data = selfData.value
  if (!data) return null
  return data.years.find((y) => y.year === data.latest_full_year) ?? null
})

// first year in the data (2018), for the "up from" caption
const selfFirstYear = computed(() => selfData.value?.years[0] ?? null)

const selfPartialYear = computed(() => {
  const years = selfData.value?.years ?? []
  const last = years[years.length - 1]
  return last && last.partial_year ? last : null
})

// "536K" style headline, in the reader's own number format
const selfHeadline = computed(() => {
  const n = selfLatestYear.value?.self_collected
  if (n == null) return '—'
  return new Intl.NumberFormat(undefined, { notation: 'compact', maximumFractionDigits: 0 }).format(
    n,
  )
})

const selfYMax = computed(() => (selfMode.value === 'share' ? 50 : 60000))

const selfTicks = computed(() => {
  const share = selfMode.value === 'share'
  const values = share ? [0, 25, 50] : [0, 20000, 40000, 60000]
  return values.map((value) => ({
    value,
    y: 180 - (value / selfYMax.value) * 165,
    label: share ? `${value}%` : value === 0 ? '0' : `${value / 1000}k`,
  }))
})

const selfStep = computed(() => {
  const n = selfData.value?.months.length ?? 0
  return n > 1 ? 510 / (n - 1) : 0
})

const selfPoints = computed(() => {
  const months = selfData.value?.months ?? []
  const share = selfMode.value === 'share'
  return months.map((m, i) => {
    const value = share ? (m.self_collected_percent ?? 0) : m.self_collected
    const date = new Date(m.year, m.month - 1, 1)
    const monthName = date.toLocaleDateString(undefined, { month: 'short', year: 'numeric' })
    return {
      year: m.year,
      month: m.month,
      x: 45 + i * selfStep.value,
      y: 180 - (value / selfYMax.value) * 165,
      label: share
        ? `${monthName} · ${(m.self_collected_percent ?? 0).toFixed(1)}%`
        : `${monthName} · ${m.self_collected.toLocaleString()}`,
    }
  })
})

const selfLinePath = computed(() =>
  selfPoints.value
    .map((p, i) => `${i === 0 ? 'M' : 'L'} ${p.x.toFixed(1)} ${p.y.toFixed(1)}`)
    .join(' '),
)

const selfAreaPath = computed(() => {
  const pts = selfPoints.value
  if (!pts.length) return ''
  return `${selfLinePath.value} L ${pts[pts.length - 1].x} 180 L ${pts[0].x} 180 Z`
})

const july2022X = computed(
  () => selfPoints.value.find((p) => p.year === 2022 && p.month === 7)?.x ?? null,
)

// keep the tooltip inside the chart at the edges
const selfTooltipX = computed(() => {
  if (hoveredMonth.value === null) return 0
  const x = selfPoints.value[hoveredMonth.value].x
  return Math.min(Math.max(x, 110), 490)
})

// area disadvantage labels
function quintileLabel(q: number) {
  if (q === 1) return t('socioeconomic.q1', { ns: 'data' })
  if (q === 5) return t('socioeconomic.q5', { ns: 'data' })
  return String(q)
}
</script>
