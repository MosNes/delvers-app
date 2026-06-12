<template>
    <div class="min-h-screen flex flex-col items-center justify-center gap-4">
        <template v-if="error">
            <p class="text-red-500">{{ error }}</p>
            <RouterLink to="/" class="text-primary underline text-sm">Back to home</RouterLink>
        </template>
        <template v-else>
            <p class="text-surface-500">Signing you in…</p>
        </template>
    </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '@/lib/supabaseClient'

const router = useRouter()
const route = useRoute()
const error = ref('')

onMounted(async () => {
    const code = route.query.code

    if (code) {
        // PKCE flow: exchange the authorization code for a session
        const { error: exchangeError } = await supabase.auth.exchangeCodeForSession(String(code))
        if (exchangeError) {
            error.value = exchangeError.message
            return
        }
        router.replace('/')
        return
    }

    // Implicit flow: tokens arrive in the URL hash (#access_token=...).
    // Supabase JS v2 detects and processes the hash automatically via detectSessionInUrl.
    const { data, error: sessionError } = await supabase.auth.getSession()
    if (sessionError || !data.session) {
        error.value = sessionError?.message ?? 'Invalid or missing confirmation link.'
        return
    }

    router.replace('/')
})
</script>
