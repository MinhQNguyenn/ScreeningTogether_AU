// Mirrors ChoroplethResponse in the backend schemas.
export interface Sa3Statistic {
  sa3_code: string
  geo_name: string
  year_start: number | null
  year_end: number | null
  label: string | null
  rate_pct: number | null
  women_25_74: number | null
  pct_born_overseas: number | null 
  born_overseas_tier?: 'low' | 'mid' | 'high' | null
  pct_other_language: number | null
  pct_low_proficiency: number | null
  pct_birthplace_ns: number | null
}

// Same base URL as api/stats.ts: the live API by default, a local one if .env.local sets it
const API_BASE = import.meta.env.VITE_API_BASE_URL ?? 'https://api.screeningtogether.app'

export async function getAllSa3Statistics(): Promise<Sa3Statistic[]> {
  const url = `${API_BASE}/choropleth/all`
  const response = await fetch(url)
  const contentType = response.headers.get('content-type') ?? ''
  if (!response.ok || !contentType.includes('application/json')) {
    throw new Error(`API did not return JSON from ${url} (status ${response.status})`)
  }
  return response.json()
}
