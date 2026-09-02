export interface ScreeningStats {
  state: string
  reporting_period: string
  age_group: string
  number: number
  crude_rate: number
  as_rate: number | null
}

const API_BASE_URL = 'https://api.screeningtogether.app/'

export async function getCervicalScreeningStats(
  state?: string
): Promise<ScreeningStats[]> {
  const params = new URLSearchParams()

  if (state) {
    params.append('state', state)
  }

  const query = params.toString()

  const response = await fetch(
    `${API_BASE_URL}/stats/cervical-screening${query ? `?${query}` : ''}`
  )

  if (!response.ok) {
    throw new Error('Failed to fetch cervical screening statistics')
  }

  return response.json()
}