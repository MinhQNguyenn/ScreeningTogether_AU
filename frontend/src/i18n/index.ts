import i18next from 'i18next'
import LanguageDetector from 'i18next-browser-languagedetector'

// Header in App.vue
import enCommon from './locales/en/common.json'
import zhHKCommon from './locales/zh-HK/common.json'
import zhCNCommon from './locales/zh-CN/common.json'
import arCommon from './locales/ar/common.json'
import viCommon from './locales/vi/common.json'

// HomeView.vue
import enHome from './locales/en/home.json'
import zhHKHome from './locales/zh-HK/home.json'
import zhCNHome from './locales/zh-CN/home.json'
import arHome from './locales/ar/home.json'
import viHome from './locales/vi/home.json'

// GPRunnerGameView.vue
import enGpRunner from './locales/en/gpRunner.json'
import zhHKGpRunner from './locales/zh-HK/gpRunner.json'
import zhCNGpRunner from './locales/zh-CN/gpRunner.json'
import arGpRunner from './locales/ar/gpRunner.json'
import viGpRunner from './locales/vi/gpRunner.json'



const resources = {
  en: {
    common: enCommon,
    home: enHome,
    gpRunner: enGpRunner
  },
  'zh-HK': {
    common: zhHKCommon,
    home: zhHKHome,
    gpRunner: zhHKGpRunner
  },
  'zh-CN': {
    common: zhCNCommon,
    home: zhCNHome,
    gpRunner: zhCNGpRunner
  },
  ar: {
    common: arCommon,
    home: arHome,
    gpRunner: arGpRunner
  },
  vi: {
    common: viCommon,
    home: viHome,
    gpRunner: viGpRunner
  }
}

i18next
  .use(LanguageDetector)
  .init({
    resources,
    fallbackLng: 'en',
    defaultNS: 'common',
    ns: ['common', 'home', 'gpRunner'],

    detection: {
      order: ['localStorage', 'navigator'],
      caches: ['localStorage']
    },

    interpolation: {
      escapeValue: false
    }
  })

export default i18next