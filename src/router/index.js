import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from '@/lib/supabaseClient'
import LandingPage from '../views/LandingPage.vue'
import SignUp from '../views/SignUp.vue'
import Login from '../views/Login.vue'
import AuthCallback from '../views/AuthCallback.vue'
import Dashboard from '../views/Dashboard.vue'
import CharacterSheet from '../views/CharacterSheet.vue'
import EditCharacter from '../views/EditCharacter.vue'

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
      path: '/dashboard',
      name: 'dashboard',
      component: Dashboard,
    },
    {
      path: '/character/:id',
      name: 'character',
      component: CharacterSheet,
    },
    {
      path: '/character/:id/edit',
      name: 'edit-character',
      component: EditCharacter,
    },
    {
      path: '/new-character',
      name: 'new-character',
      component: EditCharacter,
    },
  ],
})

// Guard runs before every navigation.
// getSession() is used directly (rather than the useAuth composable) because
// it is reliably awaitable here, before any component has mounted.
router.beforeEach(async (to) => {
  const { data: { session } } = await supabase.auth.getSession()
  const isAuthed = !!session

  if (to.name === 'dashboard' && !isAuthed) return { name: 'home' }
  if (to.name === 'new-character' && !isAuthed) return { name: 'home' }
  if (to.name === 'home' && isAuthed) return { name: 'dashboard' }
})

export default router
