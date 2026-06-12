import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabasePublishableKey = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY

// Cookie-based session storage. Cannot use httpOnly from the browser —
// that flag requires a server-side Set-Cookie header. This is the closest
// SPA best-practice: Secure + SameSite=Strict cookies.
const cookieStorage = {
    getItem(key) {
        const match = document.cookie.match(
            new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)')
        )
        return match ? decodeURIComponent(match[1]) : null
    },
    setItem(key, value) {
        const maxAge = 60 * 60 * 24 * 365
        const secure = location.protocol === 'https:' ? '; Secure' : ''
        document.cookie =
            `${encodeURIComponent(key)}=${encodeURIComponent(value)}` +
            `; max-age=${maxAge}; path=/; SameSite=Strict${secure}`
    },
    removeItem(key) {
        document.cookie =
            `${encodeURIComponent(key)}=; max-age=0; path=/; SameSite=Strict`
    },
}

export const supabase = createClient(supabaseUrl, supabasePublishableKey, {
    auth: {
        storage: cookieStorage,
        persistSession: true,
        autoRefreshToken: true,
    },
})
