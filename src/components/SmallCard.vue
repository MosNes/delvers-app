<script setup>
import Card from '@/volt/Card.vue';
import { computed } from 'vue';
const props = defineProps({
    title: {
        type: String,
        required: true
    },
    value: {
        type: Number,
        required: true,
        default: 0
    },
    maxValue: {
        type: Number,
        required: true,
        default: 0
    },
    hasMaxValue: {
        type: Boolean,
        required: true,
        default: false
    }
});

// returns true if currentValue is under 50% of maxValue
const valueCritical = computed(() => {
    return props.value < props.maxValue * 0.5;
});

</script>

<style scoped>
.attribute-card-border :deep(.rounded-xl) {
    border-radius: 0;
}
</style>

<template>
    <div class="attribute-card-border">
        <Card class="min-w-[150px] h-full" :class="{ 'pulse-box-red': valueCritical }">
            <template #header>
                <div class="text-center text-2xl font-display translate-y-4">
                    {{ title }}
                </div>
            </template>
            <template #content>
                <!-- current value changes color to red when valueCritical is true -->
                <div
                    class="text-center text-4xl font-sans rounded-lg border border-[var(--p-accent-color)] bg-[var(--p-surface-900)]"
                    :class="{ 'text-[var(--p-primary-400)]': valueCritical }">
                    {{ value }}
                </div>
                <div v-if="hasMaxValue"
                    class="text-xl text-center mt-2 border border-[var(--p-accent-color)] bg-[var(--p-surface-900)] rounded-full max-w-[50px] mx-auto mb-5">
                    <span class="font-sans">{{ maxValue }}</span>
                </div>
            </template>
        </Card>
    </div>

</template>
