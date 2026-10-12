export interface ParticipationPercentage {
  percent: number
  year_start: number
  year_end: number
  label: string
}

export interface ParticipationGraphPoint {
  year_start: number
  year_end: number
  percent: number
  label: string
}

export interface ParticipationGraph {
  state: string
  points: ParticipationGraphPoint[]
}

export interface AgeParticipationPoint {
  age_group: string // "25–29"
  percent: number
  number: number
  population: number
}
 
export interface AgeParticipation {
  state: string
  window: string // the window shown, e.g. "2020-2024"
  windows: string[] // all windows, oldest first (for the dropdown)
  points: AgeParticipationPoint[]
  highest_age_group: string
  highest_percent: number
  lowest_age_group: string
  lowest_percent: number
}

export interface SocioeconomicPoint {
  quintile: number // 1 = most disadvantaged ... 5 = least disadvantaged
  percent: number
  number: number
}
 
export interface SocioeconomicParticipation {
  window: string
  windows: string[]
  points: SocioeconomicPoint[]
}

export interface SelfCollectionMonth {
  year: number
  month: number
  self_collected: number
  all_tests: number
  self_collected_percent: number | null
}
 
export interface SelfCollectionYear {
  year: number
  months_covered: number
  partial_year: boolean
  self_collected: number
  all_tests: number
  self_collected_percent: number | null
}
 
export interface SelfCollection {
  months: SelfCollectionMonth[]
  years: SelfCollectionYear[]
  latest_full_year: number
}


// Live API by default. For local testing, create frontend/.env.local with
// VITE_API_BASE_URL=http://127.0.0.1:8000
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'https://api.screeningtogether.app'

export async function getParticipationPercentage(): Promise<ParticipationPercentage> {
  const response = await fetch(
    `${API_BASE_URL}/stats/participation-percentage`
  )

  if (!response.ok) {
    throw new Error('Failed to fetch participation percentage')
  }

  return response.json()
}

export async function getParticipationGraph(
  state: string
): Promise<ParticipationGraph> {
  const response = await fetch(
    `${API_BASE_URL}/stats/participation-graph?state=${encodeURIComponent(state)}`
  )

  if (!response.ok) {
    throw new Error('Failed to fetch participation graph')
  }

  return response.json()
}

export async function getParticipationByAge(
  state: string,
  window?: string
): Promise<AgeParticipation> {
  const params = new URLSearchParams({ state })
  if (window) params.set('window', window)

  const response = await fetch(`${API_BASE_URL}/stats/participation-age?${params}`)

  if (!response.ok) {
    throw new Error('Failed to fetch participation by age')
  }

  return response.json()
}

export async function getParticipationBySocioeconomic(
  window?: string
): Promise<SocioeconomicParticipation> {
  const params = new URLSearchParams()
  if (window) params.set('window', window)

  const response = await fetch(`${API_BASE_URL}/stats/participation-socioeconomic?${params}`)

  if (!response.ok) {
    throw new Error('Failed to fetch participation by area disadvantage')
  }

  return response.json()
}

export async function getSelfCollection(): Promise<SelfCollection> {
  const response = await fetch(`${API_BASE_URL}/stats/self-collection`)

  if (!response.ok) {
    throw new Error('Failed to fetch self-collection data')
  }

  return response.json()
}

export async function iteration1GetParticipationPercentage(): Promise<ParticipationPercentage> {
  const response = await fetch(
    `${API_BASE_URL}/stats/participation-percentage`
  )

  if (!response.ok) {
    throw new Error('Failed to fetch participation percentage')
  }

  return response.json()
}

export async function iteration1GetParticipationGraph(
  state: string
): Promise<ParticipationGraph> {
  const response = await fetch(
    `${API_BASE_URL}/stats/participation-graph?state=${encodeURIComponent(state)}`
  )

  if (!response.ok) {
    throw new Error('Failed to fetch participation graph')
  }

  return response.json()
}