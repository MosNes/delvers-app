<template>
    <div class="min-h-screen flex flex-col items-center justify-center gap-6">
        <template v-if="!submitted">
            <h1 class="text-3xl font-bold">Log In</h1>

            <form class="flex flex-col gap-4 w-full max-w-sm" @submit.prevent="handleLogin">
                <div class="flex flex-col gap-1">
                    <label for="email" class="text-sm font-medium">Email</label>
                    <InputText
                        id="email"
                        v-model="email"
                        type="email"
                        placeholder="you@example.com"
                        :invalid="!!errors.email"
                        unstyled
                        :pt="inputTheme"
                    />
                    <small v-if="errors.email" class="text-red-500">{{ errors.email }}</small>
                </div>

                <small v-if="authError" class="text-red-500 text-center">{{ authError }}</small>

                <Button
                    type="submit"
                    label="Send Magic Link"
                    :loading="loading"
                    class="w-full mt-2"
                />
            </form>

            <p class="text-sm text-surface-500">
                Don't have an account?
                <RouterLink to="/signup" class="text-primary underline">Sign up</RouterLink>
            </p>
        </template>

        <template v-else>
            <h1 class="text-3xl font-bold">Check your email</h1>
            <p class="text-surface-500 text-center max-w-sm">
                We sent a magic link to <strong>{{ email }}</strong>.
                Click the link to sign in.
            </p>
        </template>
    </div>
</template>

<script setup>
import { ref } from 'vue'
import InputText from 'primevue/inputtext'
import Button from '@/volt/Button.vue'
import { supabase } from '@/lib/supabaseClient'

const email = ref('')
const loading = ref(false)
const authError = ref('')
const errors = ref({})
const submitted = ref(false)

const inputTheme = {
    root: `block w-full rounded-md border border-surface-300 bg-surface-0 px-3 py-2 text-sm
           text-surface-900 placeholder:text-surface-400
           focus:outline focus:outline-1 focus:outline-offset-2 focus:outline-primary
           disabled:opacity-60
           dark:border-surface-600 dark:bg-surface-900 dark:text-surface-0`,
}

function validate() {
    const e = {}
    if (!email.value.trim()) e.email = 'Email is required.'
    errors.value = e
    return Object.keys(e).length === 0
}

async function handleLogin() {
    authError.value = ''
    if (!validate()) return

    loading.value = true
    const { error } = await supabase.auth.signInWithOtp({
        email: email.value.trim(),
        options: {
            shouldCreateUser: false,
            emailRedirectTo: `${location.origin}/auth/callback`,
        },
    })
    loading.value = false

    if (error) {
        authError.value = error.message
        return
    }

    submitted.value = true
}
</script>
