import { reactive } from 'vue'

export const authState = reactive({
  visible: false,
})

let resolveLogin: ((success: boolean) => void) | null = null

export function requestAuth(): Promise<boolean> {
  if (sessionStorage.getItem('iteration-authenticated') === 'true') {
    return Promise.resolve(true)
  }

  authState.visible = true

  return new Promise<boolean>((resolve) => {
    resolveLogin = resolve
  })
}

export function resolveAuth(success: boolean) {
  authState.visible = false

  if (resolveLogin) {
    resolveLogin(success)
    resolveLogin = null
  }
}
