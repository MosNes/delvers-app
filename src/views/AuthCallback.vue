<template>
    <div class="min-h-screen flex flex-col items-center justify-center gap-4">
        <LoadingState :is-error="dataState.isError" :error-message="errorMessage" />
        <RouterLink v-if="dataState.isError" to="/" class="text-primary underline text-sm">Back to home</RouterLink>
    </div>
</template>

<script setup>
import { onMounted, ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '@/lib/supabaseClient'
import LoadingState from '@/components/LoadingState.vue'

const router = useRouter()
const route = useRoute()
const dataState = reactive({ isLoaded: false, isError: false })
const errorMessage = ref('')

onMounted(async () => {
    const code = route.query.code

    if (code) {
        const { error: exchangeError } = await supabase.auth.exchangeCodeForSession(String(code))
        if (exchangeError) {
            errorMessage.value = exchangeError.message
            dataState.isError = true
            return
        }
        router.replace('/')
        return
    }

    const { data, error: sessionError } = await supabase.auth.getSession()
    if (sessionError || !data.session) {
        errorMessage.value = sessionError?.message ?? 'Invalid or missing confirmation link.'
        dataState.isError = true
        return
    }

    router.replace('/')
})
</script>
