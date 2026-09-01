<template>
  <main class="finder-page">
    <section class="finder-hero">
      <div class="finder-hero-inner">
        <p class="eyebrow"><span class="eyebrow-dot"></span> Find care near you</p>
        <h1>GP Finder</h1>
        <form class="search-card" @submit.prevent="searchLocation">
          <label for="location"
            ><span class="pin-icon">⌖</span><em>Enter suburb or postcode</em></label
          >
          <div class="search-input">
            <span>⌕</span
            ><input
              id="location"
              v-model="location"
              placeholder="Clayton, VIC 3168"
              aria-label="Suburb or postcode"
            /><button type="submit" aria-label="Search">→</button>
          </div>
        </form>
      </div>
      <button class="locate-button" aria-label="Use current location" type="button">⌖</button>
    </section>
    <section class="results-section">
      <div class="results-toolbar">
        <button class="filter-button" type="button" @click="showFilters = !showFilters">
          Filter <span :class="{ rotate: showFilters }"></span>
        </button>
        <label class="sort-control"
          >Sort by:
          <select v-model="sortOrder" aria-label="Sort services by distance">
            <option value="nearest">Nearest</option>
            <option value="furthest">Furthest</option>
          </select>
        </label>
      </div>
      <div v-if="showFilters" class="filter-panel">
        <label><input type="checkbox" checked /> Accessible services</label
        ><label><input type="checkbox" /> Bulk billing</label
        ><label><input type="checkbox" /> Open today</label>
      </div>
      <article v-for="service in sortedServices" :key="service.name" class="service-card">
        <div>
          <h2>{{ service.name }}</h2>
          <p class="service-type">{{ service.type }}</p>
          <p class="service-details">
            ⌖ {{ service.address }}<br />♧ {{ service.phone }}<br />♿ {{ service.access }}
          </p>
        </div>
        <div class="service-actions">
          <span class="distance">{{ service.distance }}</span
          ><button type="button" class="details-button">
            <span class="brand-mark">✳</span> &nbsp; View Details
          </button>
        </div>
      </article>
    </section>
  </main>
</template>

<script setup lang="ts">
import '../assets/gpFinder.css'
import { computed, ref } from 'vue'

const location = ref('')
const showFilters = ref(false)
const sortOrder = ref<'nearest' | 'furthest'>('nearest')
const services = [
  {
    name: 'Monash University Health Service - Clayton',
    type: 'GP (General Practice)',
    address: '21 Chancellor’s Walk Clayton VIC 3168',
    phone: '03 9905 3175',
    access: 'Accessible toilet, wheelchair accessible, accessible parking',
    distance: '0.7 km',
    distanceValue: 0.7,
  },
  {
    name: 'South Eastern Community Health - Oakleigh',
    type: 'GP (General Practice)',
    address: '2A High Street Oakleigh VIC 3166',
    phone: '03 9563 6500',
    access: 'Wheelchair accessible, accessible parking',
    distance: '2.4 km',
    distanceValue: 2.4,
  },
]
const sortedServices = computed(() =>
  [...services].sort((a, b) =>
    sortOrder.value === 'nearest'
      ? a.distanceValue - b.distanceValue
      : b.distanceValue - a.distanceValue,
  ),
)
const searchLocation = () => {
  if (!location.value) location.value = 'Clayton, VIC 3168'
}
</script>
