<script setup>
const props = defineProps({
    title: {
        type: String,
        required: true
    },
    value: {
        type: Number,
        required: true,
        default: 0
    }
})
</script>

<template>
    <Card class="min-w-[150px] attribute-card-border">
        <template #header>
            <div class="text-center text-lg font-display">
                {{ title }}
            </div>
        </template>
        <template #content>
            <div
                class="text-center text-6xl font-sans rounded-lg border border-[var(--p-accent-color)] bg-[var(--p-surface-900)] p-2">
                {{value }}
            </div>
        </template>
    </Card>
</template>
