import { createRouter, createWebHistory } from 'vue-router'

import PlaceholderView from '../views/PlaceholderView.vue'
import EducationGame from '../views/GameView.vue'
import HomeView from '../views/HomeView.vue'
import GpFinder from '../views/GpFinderView.vue'
import GPRunnerGameView from '../views/GpRunnerGameView.vue'
import GPDetailsView from '../views/GpFinderDetailView.vue'
import Game2View from '../views/Game2View.vue'
import Game3View from '../views/Game3View.vue'

//Iteration 1
import Iteration1Home from "../views/Iteration 1/HomeView.vue"
import Iteration1Game1 from "../views/Iteration 1/GpRunnerGameView.vue"

//Iteration 2
import Iteration2HomeView from '../views/Iteration 2/HomeView.vue'
import Iteration2GpFinder from '../views/Iteration 2/GpFinderView.vue'
import Iteration2GPRunnerGameView from '../views/Iteration 2/GpRunnerGameView.vue'
import Iteration2Game2View from '../views/Iteration 2/Game2View.vue'
import Iteration2Game3View from '../views/Iteration 2/Game3View.vue'

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
      path: '/game2',
      component: Game2View,
      meta: { title: 'Waiting Room Practice | ScreeningTogether AU' },
    },
    {
      path: '/game3',
      component: Game3View,
      meta: { title: 'A few minutes with Luna | ScreeningTogether AU' },
    },
    { path: '/details', component: GPDetailsView, meta: { title: 'GP Details | ScreeningTogether AU' } },


    // ROUTER FOR ITERATION 1
    { path: '/iteration1', component: Iteration1Home, meta: { title: 'Home | ScreeningTogether AU' } },
    {
      path: '/iteration1/gprunner',
      component: Iteration1Game1,
      meta: { title: 'Screening Pathways | ScreeningTogether AU' },
    },

    // ROUTER FOR ITERATION 2
    { path: '/iteration2', component: Iteration2HomeView, meta: { title: 'Home | ScreeningTogether AU' } },
    { path: '/iteration2/game', component: Iteration2GPRunnerGameView, meta: { title: 'Games | ScreeningTogether AU' } },
    { path: '/iteration2/gpfinder', component: Iteration2GpFinder, meta: { title: 'GP Finder | ScreeningTogether AU' } },
    {
      path: '/iteration2/gprunner',
      component: Iteration2GPRunnerGameView,
      meta: { title: 'Screening Pathways | ScreeningTogether AU' },
    },
    {
      path: '/iteration2/game2',
      component: Iteration2Game2View,
      meta: { title: 'Waiting Room Practice | ScreeningTogether AU' },
    },
    {
      path: '/iteration2/game3',
      component: Iteration2Game3View,
      meta: { title: 'A few minutes with Luna | ScreeningTogether AU' },
    },
  ],
})

router.afterEach((to) => {
  console.log('Current route:', to.path)
  console.log('Title:', to.meta.title)

  document.title = (to.meta.title as string) || 'ScreeningTogether AU'
})

export default router
