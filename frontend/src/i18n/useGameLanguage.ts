import { onBeforeUnmount, onMounted, watch, type Ref } from 'vue'
import { useTranslation } from './useTranslation'

export function normaliseGameLanguage(language: string): string {
  const code = language.replace(/_/g, '-').toLowerCase()
  if (code.startsWith('ar')) return 'ar'
  if (code.startsWith('vi')) return 'vi'
  if (code.startsWith('yue') || ['zh-hk', 'zh-tw', 'zh-hant', 'zh-hant-hk'].includes(code)) return 'zh-HK'
  if (code.startsWith('zh')) return 'zh-CN'
  return 'en'
}

/** Sync the iframe without reloading an in-progress run or appointment. */
export function useGameLanguage(frame: Ref<HTMLIFrameElement | null>) {
  const { currentLanguage, changeLanguage } = useTranslation()
  const initialLanguage = normaliseGameLanguage(currentLanguage.value)
  const sendLanguage = () => {
    frame.value?.contentWindow?.postMessage(
      { type: 'screening-language', language: normaliseGameLanguage(currentLanguage.value) },
      window.location.origin,
    )
  }
  const receiveMessage = (event: MessageEvent) => {
    if (event.origin !== window.location.origin || event.source !== frame.value?.contentWindow) return
    if (event.data?.type === 'screening-game-ready') sendLanguage()
    if (event.data?.type === 'screening-language-changed' && typeof event.data.language === 'string') {
      void changeLanguage(normaliseGameLanguage(event.data.language))
    }
  }
  watch(currentLanguage, sendLanguage)
  onMounted(() => window.addEventListener('message', receiveMessage))
  onBeforeUnmount(() => window.removeEventListener('message', receiveMessage))
  return { initialLanguage, sendLanguage }
}
