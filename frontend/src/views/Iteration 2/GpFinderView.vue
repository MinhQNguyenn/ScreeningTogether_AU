<template>
  <main class="finder-page">
    <section class="finder-hero">
      <div class="finder-hero-inner">
        <p class="eyebrow">
          <span class="eyebrow-dot"></span> {{ t('findCare', { ns: 'gpFinder' }) }}
        </p>
        <h1>{{ t('title', { ns: 'gpFinder' }) }}</h1>
        <form class="search-card" @submit.prevent="searchLocation">
          <label for="location">
            <button
              class="pin-icon"
              :aria-label="t('useCurrentLocation', { ns: 'gpFinder' })"
              type="button"
            >
              ⌖
            </button>
            <em>{{ t('enterLocation', { ns: 'gpFinder' }) }}</em>
          </label>
          <div class="search-input">
            <span>⌕</span>
            <input
              id="location"
              v-model="location"
              :placeholder="t('placeholder', { ns: 'gpFinder' })"
              :aria-label="t('locationInput', { ns: 'gpFinder' })"
            />
          </div>
        </form>
      </div>
    </section>
    <section class="results-section">
      <!-- Loading state -->
      <p v-if="loading" class="results-message">{{ t('searching', { ns: 'gpFinder' }) }}</p>
      <!-- Error state -->
      <p v-else-if="errorMessage" class="results-message error-message">{{ errorMessage }}</p>
      <!-- No results state -->
      <p v-else-if="hasSearched && services.length === 0" class="results-message">
        {{ t('noResults', { ns: 'gpFinder' }) }}
      </p>
      <!-- GP results -->
      <div
        v-for="service in sortedServices"
        :key="`${service.name}-${service.postcode}`"
        class="service-card"
      >
        <div>
          <!-- Keep GP name as returned by API -->
          <h2>{{ service.name }}</h2>
          <!-- Translate fixed service type -->
          <p class="service-type">{{ t('generalPractice', { ns: 'gpFinder' }) }}</p>
          <!-- Keep real address information unchanged -->
          <p class="service-details">
            🏘 {{ service.address }}<br />
            ⌖ {{ service.suburb }}, {{ translatedState(service.state) }} {{ service.postcode }}
          </p>
        </div>
      </div>
    </section>
  </main>
</template>
<script setup lang="ts">
import '../../assets/iteration2/gpFinder.css'
import { computed, ref } from 'vue'
import { getGPsByPostcode, type GP } from '../../api/gpFinder'
import { useTranslation } from '../../i18n/useTranslation'
const { t } = useTranslation()
const location = ref('')
const services = ref<GP[]>([])
const loading = ref(false)
const hasSearched = ref(false)
const errorMessage = ref('')

/* * Keep the API result order for now. */
const sortedServices = computed(() => {
  return [...services.value]
})

/* * Translate Australian state abbreviations * returned by the API. */
const translatedState = (state: string) => {
  const map: Record<string, string> = {
    VIC: t('states.victoria', { ns: 'gpFinder' }),
    NSW: t('states.newSouthWales', { ns: 'gpFinder' }),
    QLD: t('states.queensland', { ns: 'gpFinder' }),
    SA: t('states.southAustralia', { ns: 'gpFinder' }),
    WA: t('states.westernAustralia', { ns: 'gpFinder' }),
    TAS: t('states.tasmania', { ns: 'gpFinder' }),
    NT: t('states.northernTerritory', { ns: 'gpFinder' }),
    ACT: t('states.australianCapitalTerritory', { ns: 'gpFinder' }),
  }
  return map[state] || state
}
/* * Search GP services by postcode. */
const searchLocation = async () => {
  errorMessage.value = ''
  hasSearched.value = false
  const input = location.value.trim()
  if (!input) {
    errorMessage.value = t('postcodeRequired', { ns: 'gpFinder' })
    return
  }
  const postcodeMatch = input.match(/\b\d{4}\b/)
  if (!postcodeMatch) {
    errorMessage.value = t('invalidPostcode', { ns: 'gpFinder' })
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
    errorMessage.value = t('searchError', { ns: 'gpFinder' })
  } finally {
    loading.value = false
  }
}
</script>
