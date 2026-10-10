<template>
  <section class="choropleth-section" aria-labelledby="choropleth-title">
    <p class="section-label">{{ t('map.eyebrow', ns) }}</p>
    <h2 id="choropleth-title">{{ t('map.title', ns) }}</h2>
    <p class="choropleth-intro">{{ t('map.description', ns) }}</p>

    <div class="choropleth-toolbar">
      <div class="choropleth-field choropleth-search">
        <label for="sa3-search">{{ t('map.searchLabel', ns) }}</label>
        <div class="choropleth-search-box">
          <input
            id="sa3-search"
            v-model="query"
            type="search"
            autocomplete="off"
            role="combobox"
            aria-autocomplete="list"
            aria-controls="sa3-results"
            :aria-expanded="searchOpen && query.trim().length > 0"
            :placeholder="t('map.searchPlaceholder', ns)"
            @input="onSearchInput"
            @focus="searchOpen = true"
            @blur="searchOpen = false"
            @keydown="onSearchKeydown"
          />
          <ul
            v-if="searchOpen && query.trim()"
            id="sa3-results"
            class="choropleth-results"
            role="listbox"
          >
            <li
              v-for="(result, index) in results"
              :key="result.code"
              role="option"
              :aria-selected="index === activeIndex"
              :class="{ active: index === activeIndex }"
              @mousedown.prevent="pickResult(result)"
            >
              {{ result.name }}
            </li>
            <li v-if="!results.length" class="choropleth-no-results">
              {{ t('map.noResults', ns) }}
            </li>
          </ul>
        </div>
      </div>

      <div class="choropleth-field">
        <label for="sa3-metric">{{ t('map.metricLabel', ns) }}</label>
        <select id="sa3-metric" v-model="metric">
          <option v-for="m in METRICS" :key="m.key" :value="m.key">
            {{ t(`map.metrics.${m.key}`, ns) }}
          </option>
        </select>
      </div>

      <button type="button" class="choropleth-reset" @click="resetView">
        {{ t('map.resetView', ns) }}
      </button>
    </div>

    <div class="choropleth-layout">
      <div class="choropleth-map-wrap">
        <div
          ref="mapEl"
          class="choropleth-map"
          role="region"
          :aria-label="t('map.ariaLabel', ns)"
        ></div>
        <button
          type="button"
          class="choropleth-map-reset"
          :aria-label="t('map.resetView', ns)"
          :title="t('map.resetView', ns)"
          @click="resetView"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            aria-hidden="true"
          >
            <path d="M3 11a9 9 0 1 1 2.5 6.2" />
            <path d="M3 4v7h7" />
          </svg>
        </button>
        <p v-if="loading" class="choropleth-status">{{ t('map.loading', ns) }}</p>
        <p v-else-if="error" class="choropleth-status choropleth-error">{{ error }}</p>
      </div>

      <aside class="choropleth-panel">
        <h3>{{ t(`map.metrics.${metric}`, ns) }}</h3>
        <ul class="choropleth-legend">
          <li v-for="item in legend" :key="item.label">
            <span class="swatch" :style="{ background: item.color }"></span>{{ item.label }}
          </li>
          <li>
            <span class="swatch" :style="{ background: NO_DATA_COLOR }"></span>
            {{ t('map.noData', ns) }}
          </li>
        </ul>

        <div class="choropleth-detail" aria-live="polite">
          <template v-if="selectedStat">
            <h3>{{ selectedStat.geo_name }}</h3>
            <dl>
              <div>
                <dt>{{ t('map.metrics.participation', ns) }}</dt>
                <dd>
                  {{ fmtPct(selectedStat.rate_pct) }}
                  <small v-if="selectedStat.label">({{ selectedStat.label }})</small>
                </dd>
              </div>
              <div>
                <dt>{{ t('map.detail.women', ns) }}</dt>
                <dd>{{ fmtCount(selectedStat.women_25_74) }}</dd>
              </div>
              <div>
                <dt>{{ t('map.metrics.bornOverseas', ns) }}</dt>
                <dd>{{ fmtPct(selectedStat.pct_born_overseas) }}</dd>
              </div>
              <div>
                <dt>{{ t('map.metrics.otherLanguage', ns) }}</dt>
                <dd>{{ fmtPct(selectedStat.pct_other_language) }}</dd>
              </div>
              <!-- <div>
                <dt>{{ t('map.metrics.lowProficiency', ns) }}</dt>
                <dd>{{ fmtPct(selectedStat.pct_low_proficiency) }}</dd>
              </div> -->
              <div>
                <dt>{{ t('map.detail.birthplaceNotStated', ns) }}</dt>
                <dd>{{ fmtPct(selectedStat.pct_birthplace_ns) }}</dd>
              </div>
            </dl>
          </template>
          <p v-else class="choropleth-hint">{{ t('map.hint', ns) }}</p>
        </div>
      </aside>
    </div>

    <p class="choropleth-note">{{ t('map.note', ns) }}</p>
  </section>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import type { Feature, FeatureCollection, Geometry } from 'geojson'

import { getAllSa3Statistics, type Sa3Statistic } from '../api/choropleth'
import { useTranslation } from '../i18n/useTranslation'

const { t } = useTranslation()
const ns = { ns: 'choropleth' }

/* ---------- Config ---------- */

// Property names in the SA3 boundary file (ABS ASGS 2021 uses SA3_CODE21)
const BOUNDARY_URL = `${import.meta.env.BASE_URL}geo/sa3.geojson`

const AUSTRALIA_BOUNDS = L.latLngBounds([-44.5, 112], [-9.5, 154.5])

// Light to dark pink, 5 classes
const RAMP = ['#fbe9e6', '#f4c9c5', '#e8a0a4', '#cf6f80', '#a84560']
const NO_DATA_COLOR = '#ffc107'

type MetricField = 'rate_pct' | 'pct_born_overseas' | 'pct_other_language' | 'pct_low_proficiency'
type MetricKey = 'participation' | 'bornOverseas' | 'otherLanguage' | 'lowProficiency'

const METRICS: { key: MetricKey; field: MetricField }[] = [
  { key: 'participation', field: 'rate_pct' },
  { key: 'bornOverseas', field: 'pct_born_overseas' },
  { key: 'otherLanguage', field: 'pct_other_language' },
  //  { key: 'lowProficiency', field: 'pct_low_proficiency' },
]

/* ---------- State ---------- */

const mapEl = ref<HTMLDivElement | null>(null)
let map: L.Map | null = null
let geoLayer: L.GeoJSON | null = null
let labelLayer: L.LayerGroup | null = null

const layersByCode = new Map<string, L.Polygon>()

const stats = ref<Record<string, Sa3Statistic>>({})
const loading = ref(true)
const error = ref('')

const metric = ref<MetricKey>('participation')
const selectedCode = ref<string | null>(null)

const query = ref('')
const searchOpen = ref(false)
const activeIndex = ref(0)

const metricField = computed<MetricField>(() => METRICS.find((m) => m.key === metric.value)!.field)

const selectedStat = computed(() =>
  selectedCode.value ? (stats.value[selectedCode.value] ?? null) : null,
)

/* ---------- Colour scale (quantiles of the current metric) ---------- */

const classBreaks = computed(() => {
  const values = Object.values(stats.value)
    .map((s) => s[metricField.value])
    .filter((v): v is number => typeof v === 'number')
    .sort((a, b) => a - b)

  if (!values.length) {
    return { thresholds: [] as number[], min: 0, max: 0 }
  }

  const thresholds = [1, 2, 3, 4].map(
    (i) => values[Math.min(values.length - 1, Math.floor((i * values.length) / 5))],
  )
  return { thresholds, min: values[0], max: values[values.length - 1] }
})

function classIndex(value: number): number {
  let index = 0
  for (const threshold of classBreaks.value.thresholds) {
    if (value >= threshold) index++
  }
  return index
}

const legend = computed(() => {
  const { thresholds, min, max } = classBreaks.value
  if (!thresholds.length) return []
  return RAMP.map((color, i) => {
    const lo = i === 0 ? min : thresholds[i - 1]
    const hi = i === RAMP.length - 1 ? max : thresholds[i]
    return { color, label: `${lo.toFixed(0)}–${hi.toFixed(0)}%` }
  })
})

function valueFor(code: string): number | null {
  return stats.value[code]?.[metricField.value] ?? null
}

function styleFor(code: string): L.PathOptions {
  const value = valueFor(code)
  const isSelected = code === selectedCode.value
  return {
    fillColor: value === null ? NO_DATA_COLOR : RAMP[classIndex(value)],
    fillOpacity: 0.92,
    color: isSelected ? '#302a2d' : '#fffaf8',
    weight: isSelected ? 2.5 : 0.6,
  }
}

function applyStyle(code: string) {
  const layer = layersByCode.get(code)
  if (!layer) return
  layer.setStyle(styleFor(code))
  if (code === selectedCode.value) layer.bringToFront()
}

function restyleAll() {
  for (const code of layersByCode.keys()) applyStyle(code)
}

watch(metric, restyleAll)

/* ---------- Formatting ---------- */

const fmtPct = (v: number | null | undefined) =>
  v === null || v === undefined ? '—' : `${v.toFixed(1)}%`

const fmtCount = (v: number | null | undefined) =>
  v === null || v === undefined ? '—' : Math.round(v).toLocaleString()

/* ---------- Map ---------- */

function codeOf(feature: Feature | undefined): string | null {
  const p = (feature?.properties ?? {}) as Record<string, unknown>
  const v = p.SA3_CODE21 ?? p.SA3_CODE_2021 ?? p.sa3_code ?? p.code
  return v === null || v === undefined ? null : String(v)
}

function nameOf(feature: Feature | undefined): string {
  const p = (feature?.properties ?? {}) as Record<string, unknown>
  return String(p.SA3_NAME21 ?? p.SA3_NAME_2021 ?? p.sa3_name ?? p.name ?? '')
}

function pointInPolygon(point: L.LatLng, polygon: L.Polygon): boolean {
  const rings = polygon.getLatLngs()
  const latLngRings = Array.isArray(rings[0]) ? (rings as L.LatLng[][]) : [rings as L.LatLng[]]

  const x = point.lng
  const y = point.lat

  return latLngRings.some((ring) => {
    let inside = false

    for (let i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      const xi = ring[i].lng
      const yi = ring[i].lat
      const xj = ring[j].lng
      const yj = ring[j].lat

      const intersects = yi > y !== yj > y && x < ((xj - xi) * (y - yi)) / (yj - yi) + xi

      if (intersects) inside = !inside
    }

    return inside
  })
}

function findLabelPosition(polygon: L.Polygon): L.LatLng {
  const bounds = polygon.getBounds()
  const center = bounds.getCenter()

  if (pointInPolygon(center, polygon)) return center

  // Try progressively smaller offsets around the bounding-box centre.
  const latSpan = bounds.getNorth() - bounds.getSouth()
  const lngSpan = bounds.getEast() - bounds.getWest()

  for (const factor of [0.2, -0.2, 0.35, -0.35, 0.1, -0.1]) {
    for (const [latFactor, lngFactor] of [
      [factor, 0],
      [0, factor],
      [factor, factor],
      [factor, -factor],
      [-factor, factor],
      [-factor, -factor],
    ]) {
      const candidate = L.latLng(center.lat + latSpan * latFactor, center.lng + lngSpan * lngFactor)

      if (pointInPolygon(candidate, polygon)) return candidate
    }
  }

  // Fallback if no candidate is found.
  return center
}

function addAreaLabel(polygon: L.Polygon, areaName: string, code: string) {
  if (!map || !areaName.trim()) return

  const labelElement = document.createElement('span')
  labelElement.textContent = areaName

  const icon = L.divIcon({
    className: 'sa3-area-label',
    html: labelElement,
    iconSize: [110, 30],
    iconAnchor: [55, 15],
  })

  const marker = L.marker(findLabelPosition(polygon), {
    icon,
    title: code,
    interactive: false,
    keyboard: false,
    pane: 'sa3Labels',
  })

  labelLayer?.addLayer(marker)
}

function updateAreaLabelVisibility() {
  if (!map || !labelLayer) return

  const mapBounds = map.getBounds()
  const mapSize = map.getSize()

  labelLayer.eachLayer((layer) => {
    const marker = layer as L.Marker
    const code = marker.options.title
    const polygon = code ? layersByCode.get(code) : undefined

    if (!polygon) {
      map!.removeLayer(marker)
      return
    }

    const bounds = polygon.getBounds()

    // Hide labels for areas outside the current viewport.
    if (!bounds.intersects(mapBounds)) {
      map!.removeLayer(marker)
      return
    }

    // Estimate how much screen space the area's bounding box occupies.
    const northWest = map!.latLngToContainerPoint(bounds.getNorthWest())
    const southEast = map!.latLngToContainerPoint(bounds.getSouthEast())

    const width = Math.abs(southEast.x - northWest.x)
    const height = Math.abs(southEast.y - northWest.y)
    const screenArea = width * height

    // Show labels only when the area's bounding box is large enough.
    const showLabel = screenArea >= 12000 && width >= 90 && height >= 45

    if (showLabel) {
      if (!map!.hasLayer(marker)) marker.addTo(map!)
    } else {
      map!.removeLayer(marker)
    }
  })
}

function buildTooltip(code: string, fallbackName: string): HTMLElement {
  const el = document.createElement('div')
  const name = document.createElement('strong')
  name.textContent = stats.value[code]?.geo_name ?? fallbackName
  const line = document.createElement('div')
  const value = valueFor(code)
  line.textContent = `${t(`map.metrics.${metric.value}`, ns)}: ${
    value === null ? t('map.noData', ns) : fmtPct(value)
  }`
  el.append(name, line)
  return el
}

function prefersReducedMotion() {
  return window.matchMedia('(prefers-reduced-motion: reduce)').matches
}

function zoomTo(code: string) {
  const layer = layersByCode.get(code)
  if (!map || !layer) return

  map.flyToBounds(layer.getBounds(), {
    padding: [40, 40],
    maxZoom: 11,
    animate: !prefersReducedMotion(),
    duration: 1.2,
  })
}

function selectArea(code: string, zoom: boolean) {
  const previous = selectedCode.value
  selectedCode.value = code
  if (previous) applyStyle(previous)
  applyStyle(code)
  if (zoom) zoomTo(code)
}

function resetView() {
  const previous = selectedCode.value
  selectedCode.value = null
  if (previous) applyStyle(previous)
  query.value = ''
  map?.fitBounds(AUSTRALIA_BOUNDS, { animate: !prefersReducedMotion() })
}

function buildLayer(geo: FeatureCollection<Geometry>) {
  if (!map) return

  // Recreate the label layer whenever the GeoJSON layer is rebuilt.
  labelLayer?.remove()
  labelLayer = L.layerGroup().addTo(map)

  // Keep labels above the polygons without intercepting mouse events.
  if (!map.getPane('sa3Labels')) {
    map.createPane('sa3Labels')
  }

  const labelPane = map.getPane('sa3Labels')
  if (labelPane) {
    labelPane.style.zIndex = '650'
    labelPane.style.pointerEvents = 'none'
  }

  const usable: FeatureCollection<Geometry> = {
    type: 'FeatureCollection',
    features: geo.features.filter((f) => f.geometry && codeOf(f)),
  }

  geoLayer = L.geoJSON(usable, {
    style: (feature) => styleFor(codeOf(feature) ?? ''),
    onEachFeature: (feature, layer) => {
      const code = codeOf(feature)
      if (!code) return
      const polygon = layer as L.Polygon
      layersByCode.set(code, polygon)

      // Display the SA3 name permanently on the map.
      addAreaLabel(polygon, nameOf(feature), code)

      polygon.bindTooltip(() => buildTooltip(code, nameOf(feature)), {
        sticky: true,
        className: 'map-tooltip',
      })
      polygon.on({
        click: () => selectArea(code, false),
        mouseover: () => {
          polygon.setStyle({ weight: 1.8, color: '#7d3e51' })
          polygon.bringToFront()
        },
        mouseout: () => applyStyle(code),
      })
    },
  }).addTo(map)

  // Update label visibility whenever the zoom level changes.
  map.on('zoomend moveend', updateAreaLabelVisibility)

  // Apply the correct visibility when the map first loads.
  updateAreaLabelVisibility()
}

/* ---------- Search ---------- */

const areas = computed(() =>
  Object.values(stats.value)
    .map((s) => ({ code: s.sa3_code, name: s.geo_name }))
    .sort((a, b) => a.name.localeCompare(b.name)),
)

const results = computed(() => {
  const q = query.value.trim().toLowerCase()
  if (!q) return []
  const matches = areas.value.filter((a) => a.name.toLowerCase().includes(q))
  matches.sort((a, b) => {
    const aStarts = a.name.toLowerCase().startsWith(q) ? 0 : 1
    const bStarts = b.name.toLowerCase().startsWith(q) ? 0 : 1
    return aStarts - bStarts
  })
  return matches.slice(0, 8)
})

function onSearchInput() {
  searchOpen.value = true
  activeIndex.value = 0
}

function pickResult(result: { code: string; name: string }) {
  query.value = result.name
  searchOpen.value = false
  selectArea(result.code, true)
}

function onSearchKeydown(event: KeyboardEvent) {
  if (event.key === 'ArrowDown') {
    event.preventDefault()
    searchOpen.value = true
    activeIndex.value = Math.min(activeIndex.value + 1, Math.max(results.value.length - 1, 0))
  } else if (event.key === 'ArrowUp') {
    event.preventDefault()
    activeIndex.value = Math.max(activeIndex.value - 1, 0)
  } else if (event.key === 'Enter') {
    const result = results.value[activeIndex.value]
    if (result) {
      event.preventDefault()
      pickResult(result)
    }
  } else if (event.key === 'Escape') {
    searchOpen.value = false
  }
}

/* ---------- Lifecycle ---------- */

onMounted(async () => {
  if (!mapEl.value) return

  map = L.map(mapEl.value, {
    preferCanvas: true,
    minZoom: 3,
    maxZoom: 16,
    zoomSnap: 1,
    zoomDelta: 0.5,
    wheelPxPerZoomLevel: 120,
    wheelDebounceTime: 40,
    worldCopyJump: false,
    zoomAnimation: true,
    fadeAnimation: true,
    markerZoomAnimation: true,
    maxBounds: AUSTRALIA_BOUNDS,
    maxBoundsViscosity: 1,
  })
  map.attributionControl.setPrefix(false)
  map.attributionControl.addAttribution('Boundaries © Australian Bureau of Statistics')
  map.fitBounds(AUSTRALIA_BOUNDS)

  try {
    const rows = await getAllSa3Statistics()

    const geoResponse = await fetch(BOUNDARY_URL)
    const contentType = geoResponse.headers.get('content-type') ?? ''
    if (!geoResponse.ok || contentType.includes('text/html')) {
      throw new Error(`Boundary file not found at ${BOUNDARY_URL}`)
    }
    const geo = (await geoResponse.json()) as FeatureCollection<Geometry>

    stats.value = Object.fromEntries(rows.map((r) => [String(r.sa3_code), r]))
    buildLayer(geo)
  } catch (err) {
    console.error(err)
    const detail = import.meta.env.DEV && err instanceof Error ? ` (${err.message})` : ''
    error.value = `${t('map.error', ns)}${detail}`
  } finally {
    loading.value = false
  }
})

onBeforeUnmount(() => {
  labelLayer?.clearLayers()
  labelLayer = null

  map?.remove()
  map = null
  geoLayer = null
  layersByCode.clear()
})
</script>

<style scoped>
.choropleth-section {
  margin-top: 72px;
}

.choropleth-section h2 {
  margin: 14px 0 10px;
  font-size: clamp(30px, 3.4vw, 46px);
  line-height: 1.05;
  letter-spacing: -0.05em;
  color: floralwhite;
}

.choropleth-intro {
  max-width: 560px;
  margin: 0 0 28px;
  color: #716567;
  font-size: 15px;
  line-height: 1.7;
}

/* ---------- Toolbar ---------- */
.choropleth-toolbar {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: 16px;
  margin-bottom: 18px;
}

.choropleth-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.choropleth-field label {
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: #b06b70;
}

.choropleth-search {
  flex: 1 1 260px;
  max-width: 380px;
}

.choropleth-search-box {
  position: relative;
}

.choropleth-field input,
.choropleth-field select {
  box-sizing: border-box;
  width: 100%;
  height: 44px;
  padding: 0 18px;
  border: 1px solid #d9b9b6;
  border-radius: 100px;
  background: #fffaf8;
  color: #302a2d;
  font: inherit;
  font-size: 14px;
}

.choropleth-field input:focus,
.choropleth-field select:focus {
  outline: 2px solid #e9b9a8;
  outline-offset: 2px;
}

.choropleth-results {
  position: absolute;
  top: calc(100% + 6px);
  left: 0;
  right: 0;
  z-index: 5;
  margin: 0;
  padding: 6px;
  list-style: none;
  background: #fffaf8;
  border: 1px solid #eadedb;
  border-radius: 16px;
  box-shadow: 0 12px 26px #7c555522;
  max-height: 300px;
  overflow-y: auto;
}

.choropleth-results li {
  padding: 10px 14px;
  border-radius: 10px;
  color: #302a2d;
  font-size: 14px;
  cursor: pointer;
}

.choropleth-results li.active,
.choropleth-results li:hover {
  background: #f6e1df;
}

.choropleth-results .choropleth-no-results {
  color: #8d7c7e;
  cursor: default;
}

.choropleth-results .choropleth-no-results:hover {
  background: transparent;
}

.choropleth-reset {
  height: 44px;
  padding: 0 20px;
  border: 1px solid #bd7d84;
  border-radius: 100px;
  background: #fff8f4;
  color: #9e5260;
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
}

.choropleth-reset:hover {
  background: #f6e1df;
}

/* ---------- Map + panel ---------- */
.choropleth-layout {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 300px;
  gap: 18px;
  align-items: stretch;
}

.choropleth-map-wrap {
  position: relative;
  min-height: 560px;
  border: 1px solid #eadedb;
  border-radius: 18px;
  overflow: hidden;
  background: #f8e9e9;
  isolation: isolate;
}

.choropleth-map {
  position: absolute;
  inset: 0;
  background: #352a2d;
  font-family: inherit;
}

.choropleth-status {
  position: absolute;
  top: 50%;
  left: 50%;
  z-index: 500;
  margin: 0;
  padding: 10px 18px;
  transform: translate(-50%, -50%);
  border-radius: 100px;
  background: #fffaf8;
  color: #716567;
  font-size: 13px;
  font-weight: 700;
  box-shadow: 0 8px 20px #7c555522;
}

.choropleth-error {
  color: #a24654;
}

.choropleth-panel {
  padding: 22px;
  border: 1px solid #eadedb;
  border-radius: 18px;
  background: #fffaf8;
}

.choropleth-panel h3 {
  margin: 0 0 12px;
  font-size: 15px;
  color: #332a2d;
}

.choropleth-legend {
  display: grid;
  gap: 8px;
  margin: 0 0 22px;
  padding: 0;
  list-style: none;
  font-size: 12.5px;
  color: #6e5558;
}

.choropleth-legend li {
  display: flex;
  align-items: center;
  gap: 10px;
}

.swatch {
  width: 22px;
  height: 14px;
  border: 1px solid #e0cfcc;
  border-radius: 4px;
}

.choropleth-detail {
  padding-top: 18px;
  border-top: 1px solid #eadedb;
}

.choropleth-detail dl {
  display: grid;
  gap: 12px;
  margin: 0;
}

.choropleth-detail dl div {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.choropleth-detail dt {
  font-size: 11.5px;
  color: #8d7c7e;
}

.choropleth-detail dd {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
  color: #8f3f55;
}

.choropleth-detail dd small {
  font-size: 11px;
  font-weight: 400;
  color: #8d7c7e;
}

.choropleth-hint {
  margin: 0;
  color: #806e70;
  font-size: 13px;
  line-height: 1.6;
}

.choropleth-note {
  max-width: 640px;
  margin: 18px 0 0;
  color: #8d7c7e;
  font-size: 12px;
  line-height: 1.6;
}

/* Leaflet tooltip (created outside this component's template) */
:deep(.map-tooltip) {
  padding: 8px 12px;
  border: 1px solid #d39a9a;
  border-radius: 8px;
  background: #fffaf6;
  color: #302a2d;
  font-size: 12px;
  line-height: 1.5;
  box-shadow: 0 6px 16px #7c555530;
}

:deep(.map-tooltip strong) {
  display: block;
  color: #73484e;
}

:deep(.leaflet-container) {
  font-family: inherit;
}

:deep(.leaflet-control-attribution) {
  background: #fffaf8cc;
  font-size: 10px;
}

@media (max-width: 900px) {
  .choropleth-layout {
    grid-template-columns: 1fr;
  }

  .choropleth-map-wrap {
    min-height: 420px;
  }
}

@media (max-width: 620px) {
  .choropleth-section {
    margin-top: 56px;
  }

  .choropleth-search {
    max-width: none;
  }

  .choropleth-field,
  .choropleth-reset {
    flex: 1 1 100%;
  }
}
/* Reset map button in the bottom-right corner */
.choropleth-map-reset {
  position: absolute;
  right: 16px;
  bottom: 28px;
  z-index: 1000;
  display: grid;
  place-items: center;
  width: 42px;
  height: 42px;
  padding: 0;
  border: 1px solid #eadedb;
  border-radius: 5px;
  background: #fff;
  color: #5d454b;
  box-shadow: 0 2px 6px rgb(0 0 0 / 18%);
  cursor: pointer;
  transition:
    background 0.2s ease,
    box-shadow 0.2s ease;
}
.choropleth-map-reset:hover {
  background: #f8e9e9;
  box-shadow: 0 3px 8px rgb(0 0 0 / 22%);
}
.choropleth-map-reset:focus-visible {
  outline: 2px solid #b7626d;
  outline-offset: 2px;
}
.choropleth-map-reset:active {
  background: #f6e1df;
}
@media (prefers-reduced-motion: reduce) {
  .choropleth-map-reset {
    transition: none;
  }
}

:deep(.sa3-area-label) {
  display: flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  border: none;
  color: #302a2d;
  font-family: inherit;
  font-size: 10px;
  font-weight: 700;
  line-height: 1.2;
  text-align: center;
  white-space: normal;
  overflow-wrap: break-word;
  text-shadow:
    -1px -1px 2px #fffaf8,
     1px -1px 2px #fffaf8,
    -1px  1px 2px #fffaf8,
     1px  1px 2px #fffaf8;
  pointer-events: none;
}
</style>
