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

import game3En from './locales/en/game3.json'
import game3ZhHK from './locales/zh-HK/game3.json'
import game3ZhCN from './locales/zh-CN/game3.json'
import game3Ar from './locales/ar/game3.json'
import game3Vi from './locales/vi/game3.json'

const resources = {
  en: {
    common: enCommon,
    home: enHome,
    gpRunner: enGpRunner,
    game3: game3En
  },
  'zh-HK': {
    common: zhHKCommon,
    home: zhHKHome,
    gpRunner: zhHKGpRunner,
    game3: game3ZhHK
  },
  'zh-CN': {
    common: zhCNCommon,
    home: zhCNHome,
    gpRunner: zhCNGpRunner,
    game3: game3ZhCN
  },
  ar: {
    common: arCommon,
    home: arHome,
    gpRunner: arGpRunner,
    game3: game3Ar
  },
  vi: {
    common: viCommon,
    home: viHome,
    gpRunner: viGpRunner,
    game3: game3Vi
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