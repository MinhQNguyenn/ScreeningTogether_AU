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
import enFaq from './locales/en/faq.json'
import zhHKFaq from './locales/zh-HK/faq.json'
import zhCNFaq from './locales/zh-CN/faq.json'
import arFaq from './locales/ar/faq.json'
import viFaq from './locales/vi/faq.json'
import enData from './locales/en/data.json'
import zhHKData from './locales/zh-HK/data.json'
import zhCNData from './locales/zh-CN/data.json'
import arData from './locales/ar/data.json'
import viData from './locales/vi/data.json'

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


// resoucrce page
import enResource from './locales/en/resources.json'
import zhHKResource from './locales/zh-HK/resources.json'
import zhCNResource from './locales/zh-CN/resources.json'  
import arResource from './locales/ar/resources.json'
import viResource from './locales/vi/resources.json'

// Choropleth map 
import enChoropleth from './locales/en/data-map.json'
import zhHKChoropleth from './locales/zh-HK/data-map.json'
import zhCNChoropleth from './locales/zh-CN/data-map.json'
import arChoropleth from './locales/ar/data-map.json'
import viChoropleth from './locales/vi/data-map.json'



const resources = {
  en: {
    common: enCommon,
    home: enHome,
    faq: enFaq,
    data: enData,
    gpRunner: enGpRunner,
    game3: game3En,
    gpFinder: enGpFinder,
    game2: enGame2,
    resources: enResource,
    choropleth: enChoropleth
  },
  'zh-HK': {
    common: zhHKCommon,
    home: zhHKHome,
    faq: zhHKFaq,
    data: zhHKData,
    gpRunner: zhHKGpRunner,
    game3: game3ZhHK,
    gpFinder: zhHKGpFinder,
    game2: zhHKGame2,
    resources: zhHKResource,
    choropleth: zhHKChoropleth
  },
  'zh-CN': {
    common: zhCNCommon,
    home: zhCNHome,
    faq: zhCNFaq,
    data: zhCNData,
    gpRunner: zhCNGpRunner,
    game3: game3ZhCN,
    gpFinder: zhCNGpFinder,
    game2:zhCNGame2,
    resources: zhCNResource,
    choropleth: zhCNChoropleth
  },
  ar: {
    common: arCommon,
    home: arHome,
    faq: arFaq,
    data: arData,
    gpRunner: arGpRunner,
    game3: game3Ar,
    gpFinder: arGpFinder,
    game2: arGame2,
    resources: arResource,
    choropleth: arChoropleth
  },
  vi: {
    common: viCommon,
    home: viHome,
    faq: viFaq,
    data: viData,
    gpRunner: viGpRunner,
    game3: game3Vi,
    gpFinder: viGpFinder,
    game2:viGame2,
    resources: viResource,
    choropleth: viChoropleth
  }
}

i18next
  .use(LanguageDetector)
  .init({
    resources,
    fallbackLng: 'en',
    defaultNS: 'common',
    ns: ['common', 'home', 'faq', 'data', 'gpRunner', 'game3', 'gpFinder', 'game2', 'resources', 'choropleth'],

    detection: {
      order: ['localStorage', 'navigator'],
      caches: ['localStorage']
    },

    interpolation: {
      escapeValue: false
    }
  })

export default i18next
