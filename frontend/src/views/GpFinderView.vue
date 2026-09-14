```vue
<template>
  <main class="finder-page">
    <section class="finder-hero">
      <div class="finder-hero-inner">
        <p class="eyebrow">
          <span class="eyebrow-dot"></span>
          Find care near you
        </p>

        <h1>GP Finder</h1>

        <form class="search-card" @submit.prevent="searchLocation">
          <label for="location">
            <button class="pin-icon" aria-label="Use current location" type="button">⌖</button>
            <em>Enter suburb or postcode</em>
          </label>

          <div class="search-input">
            <span>⌕</span>

            <input
              id="location"
              v-model="location"
              placeholder="Clayton, VIC 3168"
              aria-label="Suburb or postcode"
            />
          </div>
        </form>
      </div>
    </section>

    <section class="results-section">
      <div class="results-toolbar">
        <button class="filter-button" type="button" @click="showFilters = !showFilters">
          Filter
          <span :class="{ rotate: showFilters }"></span>
        </button>

        <label class="sort-control">
          Sort by:

          <select v-model="sortOrder" aria-label="Sort services by distance">
            <option value="nearest">Nearest</option>
            <option value="furthest">Furthest</option>
          </select>
        </label>
      </div>

      <!-- Filters will be connected to API data later -->
      <div v-if="showFilters" class="filter-panel">
        <label>
          <input type="checkbox" checked />
          Accessible services
        </label>

        <label>
          <input type="checkbox" />
          Bulk billing
        </label>

        <label>
          <input type="checkbox" />
          Open today
        </label>
      </div>

      <!-- Loading state -->
      <p v-if="loading" class="results-message">Searching for GPs...</p>

      <!-- Error state -->
      <p v-else-if="errorMessage" class="results-message error-message">
        {{ errorMessage }}
      </p>

      <!-- No results state -->
      <p v-else-if="hasSearched && services.length === 0" class="results-message">
        No GPs were found for this postcode.
      </p>

      <!-- GP results -->
      <RouterLink v-for="service in sortedServices" :to="`/details`" class="service-card">
        <div>
          <h2>{{ service.name }}</h2>

          <p class="service-type">GP (General Practice)</p>

          <p class="service-details">
            🏘 {{ service.address }}<br />
            ⌖ {{ service.suburb }}, {{ service.state }}
            {{ service.postcode }}
          </p>
        </div>
        <button type="button" class="details-button" @click="viewDetails(service)">
          <span class="brand-mark">✳</span>

          View Details
        </button>
      </RouterLink>
    </section>
  </main>
</template>

<script setup lang="ts">
import '../assets/gpFinder.css'
import { computed, ref } from 'vue'
import { getGPsByPostcode, type GP } from '../api/gpFinder'

const location = ref('')

const showFilters = ref(false)

const sortOrder = ref<'nearest' | 'furthest'>('nearest')

const services = ref<GP[]>([])

const loading = ref(false)

const hasSearched = ref(false)

const errorMessage = ref('')

const sortedServices = computed(() => {
  /*
   * The current GP API does not return distance.
   * It only returns latitude and longitude.
   *
   * Distance-based sorting can be implemented later
   * once the user's location is available.
   *
   * For now, preserve the API result order.
   */
  return [...services.value]
})

const searchLocation = async () => {
  errorMessage.value = ''
  hasSearched.value = false

  const input = location.value.trim()

  if (!input) {
    errorMessage.value = 'Please enter a postcode.'
    return
  }

  /*
   * The current backend endpoint only accepts a
   * four-digit postcode.
   *
   * Location/suburb suggestions will be implemented later.
   */
  const postcodeMatch = input.match(/\b\d{4}\b/)

  if (!postcodeMatch) {
    errorMessage.value = 'Please enter a valid 4-digit postcode, such as 3168.'
    return
  }

  const postcode = postcodeMatch[0]

  loading.value = true

  try {
    services.value = await getGPsByPostcode(postcode)

    hasSearched.value = true
  } catch (error) {
    console.error('GP search failed:', error)

    services.value = []

    errorMessage.value = 'Unable to find GP services right now. Please try again later.'
  } finally {
    loading.value = false
  }
}

const viewDetails = (service: GP) => {
  console.log('Selected GP:', service)

  /*
   * TODO:
   * Connect this button to the GP details API
   * when that endpoint is implemented.
   */
}
</script>
```
