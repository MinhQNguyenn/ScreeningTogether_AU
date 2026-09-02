export interface ParticipationPercentage {
  percent: number
  year_start: number
  year_end: number
}

export interface ParticipationGraphPoint {
  year_start: number
  year_end: number
  percent: number
}

export interface ParticipationGraph {
  state: string
  points: ParticipationGraphPoint[]
}

const API_BASE_URL = 'https://api.screeningtogether.app'

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