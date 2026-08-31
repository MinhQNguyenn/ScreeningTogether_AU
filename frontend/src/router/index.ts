import { createRouter, createWebHistory } from 'vue-router'
import PlaceholderView from '../views/PlaceholderView.vue'
import EducationGame from '../views/GameView.vue'
import HomeView from '../views/HomeView.vue'
import GpFinder from '../views/GpFinderView.vue'


const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', component: HomeView },
    { path: '/resources', component: PlaceholderView },
    { path: '/game', component: EducationGame },
    {path: '/gpfinder', component: GpFinder},
  ],
})

export default router
