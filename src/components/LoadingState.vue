<template>
    <div class="flex flex-col items-center justify-center gap-3 min-h-[200px]">
        <template v-if="isError">
            <p class="text-red-500 text-center">{{ errorMessage || 'Something went wrong. Please try again.' }}</p>
            <slot />
        </template>
        <template v-else>
            <ProgressSpinner />
            <p class="text-surface-500 text-sm">Loading…</p>
        </template>
    </div>
</template>

<script setup>
import ProgressSpinner from '@/volt/ProgressSpinner.vue'

defineProps({
    isError: {
        type: Boolean,
        default: false
    },
    errorMessage: {
        type: String,
        default: ''
    }
})
</script>
