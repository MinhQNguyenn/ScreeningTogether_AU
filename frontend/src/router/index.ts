import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import PlaceholderView from '../views/PlaceholderView.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', component: HomeView },
    { path: '/resources', component: PlaceholderView },
  ],
  scrollBehavior: (to) => ({ el: to.hash || '#top', behavior: 'smooth' }),
})

export default router
