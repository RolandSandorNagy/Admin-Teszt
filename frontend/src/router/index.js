import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '../views/LoginView.vue'
import AdminView from '../views/AdminView.vue'
import DynamicPageView from '../views/DynamicPageView.vue'
import { api } from '../api'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', component: LoginView },
    { path: '/admin', component: AdminView },
    { path: '/:pathMatch(.*)*', component: DynamicPageView },
  ]
})

router.beforeEach(async (to) => {
  if (to.path === '/admin') {
    try {
      await api.get('/api/me')
      return true
    } catch {
      return '/'
    }
  }
  return true
})

export default router