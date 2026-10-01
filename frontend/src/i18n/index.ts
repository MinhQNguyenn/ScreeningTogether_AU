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
// GpFinderView.vue
import enGpFinder from './locales/en/gpFinder.json'
import zhHKGpFinder from './locales/zh-HK/gpFinder.json'
import zhCNGpFinder from './locales/zh-CN/gpFinder.json'
import arGpFinder from './locales/ar/gpFinder.json'
import viGpFinder from './locales/vi/gpFinder.json'

// game2.json
import enGame2 from './locales/en/game2.json'
import zhHKGame2 from './locales/zh-HK/game2.json'
import zhCNGame2 from './locales/zh-CN/game2.json'
import arGame2 from './locales/ar/game2.json'
import viGame2 from './locales/vi/game2.json'



const resources = {
  en: {
    common: enCommon,
    home: enHome,
    gpRunner: enGpRunner,
    game3: game3En,
    gpFinder: enGpFinder,
    game2: enGame2
  },
  'zh-HK': {
    common: zhHKCommon,
    home: zhHKHome,
    gpRunner: zhHKGpRunner,
    game3: game3ZhHK,
    gpFinder: zhHKGpFinder,
    game2: zhHKGame2
  },
  'zh-CN': {
    common: zhCNCommon,
    home: zhCNHome,
    gpRunner: zhCNGpRunner,
    game3: game3ZhCN,
    gpFinder: zhCNGpFinder,
    game2:zhCNGame2
  },
  ar: {
    common: arCommon,
    home: arHome,
    gpRunner: arGpRunner,
    game3: game3Ar,
    gpFinder: arGpFinder,
    game2: arGame2
  },
  vi: {
    common: viCommon,
    home: viHome,
    gpRunner: viGpRunner,
    game3: game3Vi,
    gpFinder: viGpFinder,
    game2:viGame2
  }
}

i18next
  .use(LanguageDetector)
  .init({
    resources,
    fallbackLng: 'en',
    defaultNS: 'common',
    ns: ['common', 'home', 'gpRunner', 'game3', 'gpFinder', 'game2'],

    detection: {
      order: ['localStorage', 'navigator'],
      caches: ['localStorage']
    },

    interpolation: {
      escapeValue: false
    }
  })

export default i18next