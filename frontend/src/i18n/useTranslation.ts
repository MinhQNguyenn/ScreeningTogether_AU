
import { ref } from 'vue'
import i18next from './index'

const currentLanguage = ref(i18next.language || 'en')

i18next.on('languageChanged', (language) => {
  currentLanguage.value = language
})

export function useTranslation() {
  const t = (key: string, options?: Record<string, unknown>) => {
    // Make Vue track the current language as a reactive dependency.
    currentLanguage.value

    return i18next.t(key, options)
  }

  const changeLanguage = async (language: string) => {
    await i18next.changeLanguage(language)
  }

  return {
    t,
    changeLanguage,
    currentLanguage
  }
}

