/**
 * useAuth — shared reactive auth state for the Delvers app.
 *
 * WHY THIS EXISTS
 * ---------------
 * Multiple parts of the app (router guards, the dashboard, future protected
 * views) all need to know whether there is a logged-in user. Without a shared
 * composable each caller would open its own supabase.auth.onAuthStateChange
 * listener and call getSession() independently, creating redundant network
 * requests and listeners.
 *
 * HOW IT WORKS
 * ------------
 * The `user` ref and the auth subscription live at module scope, not inside
 * the function. This means they are created once when the module is first
 * imported, and every subsequent call to useAuth() returns the same ref —
 * all callers share a single source of truth.
 *
 * 1. getSession() seeds `user` immediately from the cookie-persisted session
 *    so components don't render an unauthenticated flash on first load.
 * 2. onAuthStateChange keeps `user` in sync for every subsequent auth event
 *    (sign-in, sign-out, token refresh, tab refocus).
 *
 * USAGE
 * -----
 *   import { useAuth } from '@/composables/useAuth'
 *   const { user } = useAuth()
 *   // `user` is a readonly ref: null when logged out, the Supabase User
 *   // object when logged in.
 */

import { ref } from 'vue'
import { supabase } from '@/lib/supabaseClient'

const user = ref(null)

// Seed from the persisted cookie session so the ref is populated before
// any component's onMounted fires.
supabase.auth.getSession().then(({ data }) => {
    user.value = data.session?.user ?? null
})

// Stay in sync with every subsequent auth state change.
supabase.auth.onAuthStateChange((_event, session) => {
    user.value = session?.user ?? null
})

export function useAuth() {
    return { user }
}
