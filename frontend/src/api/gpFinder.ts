export interface GP {
  name: string
  address: string
  suburb: string
  state: string
  postcode: string
  latitude: number | null
  longitude: number | null
}

const API_BASE_URL = 'https://api.screeningtogether.app'

export async function getGPsByPostcode(postcode: string): Promise<GP[]> {
  const response = await fetch(
    `${API_BASE_URL}/gp?postcode=${encodeURIComponent(postcode)}`
  )

  if (!response.ok) {
    throw new Error('Failed to fetch GP services')
  }

  return response.json()
}