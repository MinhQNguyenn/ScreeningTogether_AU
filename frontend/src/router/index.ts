import { createRouter, createWebHistory } from 'vue-router'

import PlaceholderView from '../views/PlaceholderView.vue'
import EducationGame from '../views/GameView.vue'
import HomeView from '../views/HomeView.vue'
import GpFinder from '../views/GpFinderView.vue'
import GPRunnerGameView from '../views/GPRunnerGameView.vue'

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
    { path: '/', component: HomeView },
    { path: '/resources', component: PlaceholderView },
    { path: '/game', component: EducationGame },
    { path: '/gpfinder', component: GpFinder },
    { path: '/gprunner', component: GPRunnerGameView },
  ],
})

export default router