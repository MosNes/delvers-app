import { createRouter, createWebHistory } from 'vue-router'
import LandingPage from '../views/LandingPage.vue'
import SignUp from '../views/SignUp.vue'
import Login from '../views/Login.vue'
import AuthCallback from '../views/AuthCallback.vue'
import CharacterSheet from '../views/CharacterSheet.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: LandingPage,
    },
    {
      path: '/signup',
      name: 'signup',
      component: SignUp,
    },
    {
      path: '/login',
      name: 'login',
      component: Login,
    },
    {
      path: '/auth/callback',
      name: 'auth-callback',
      component: AuthCallback,
    },
    {
      path: '/character',
      name: 'character',
      component: CharacterSheet,
    },
  ],
})

export default router
