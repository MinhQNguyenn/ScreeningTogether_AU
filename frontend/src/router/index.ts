import { createRouter, createWebHistory } from 'vue-router'

import PlaceholderView from '../views/PlaceholderView.vue'
import EducationGame from '../views/GameView.vue'
import HomeView from '../views/HomeView.vue'
import GpFinder from '../views/GpFinderView.vue'
import GPRunnerGameView from '../views/GpRunnerGameView.vue'
import GPDetailsView from '../views/GpFinderDetailView.vue'
import Game3View from '../views/Game3View.vue'

const router = createRouter({
  history: createWebHistory(),

  scrollBehavior(to, from, savedPosition) {
    // Restore the previous position when using browser Back/Forward
    if (savedPosition) {
      return savedPosition
    }

    // Start new pages at the top
    return { top: 0 }
  },

  routes: [
    { path: '/', component: HomeView, meta: { title: 'Home | ScreeningTogether AU' } },
    {
      path: '/resources',
      component: PlaceholderView,
      meta: { title: 'Coming Soon | ScreeningTogether AU' },
    },
    { path: '/game', component: EducationGame, meta: { title: 'Games | ScreeningTogether AU' } },
    { path: '/gpfinder', component: GpFinder, meta: { title: 'GP Finder | ScreeningTogether AU' } },
    {
      path: '/gprunner',
      component: GPRunnerGameView,
      meta: { title: 'Screening Pathways | ScreeningTogether AU' },
    },
    {
      path: '/game3',
      component: Game3View,
      meta: { title: 'A few minutes with Luna | ScreeningTogether AU' },
    },
    { path: '/details', component: GPDetailsView, meta: { title: 'GP Details | ScreeningTogether AU' } }
  ],
})

router.afterEach((to) => {
  console.log('Current route:', to.path)
  console.log('Title:', to.meta.title)

  document.title = (to.meta.title as string) || 'ScreeningTogether AU'
})

export default router
