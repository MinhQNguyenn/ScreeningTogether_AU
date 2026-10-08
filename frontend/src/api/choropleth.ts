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
  pct_other_language: number | null
  pct_low_proficiency: number | null
  pct_birthplace_ns: number | null
}

// Use the same base URL as the other functions in api/stats.ts
const API_BASE = 'https://api.screeningtogether.app'
// const API_BASE = 'http://localhost:8000'

export async function getAllSa3Statistics(): Promise<Sa3Statistic[]> {
  const url = `${API_BASE}/choropleth/all`
  const response = await fetch(url)
  const contentType = response.headers.get('content-type') ?? ''
  if (!response.ok || !contentType.includes('application/json')) {
    throw new Error(`API did not return JSON from ${url} (status ${response.status})`)
  }
  return response.json()
}
