<script setup>
import Card from '@/volt/Card.vue';
import { computed } from 'vue';

// define props
const props = defineProps({
    attributeTitle: {
        type: String,
        required: true
    },
    maxValue: {
        type: Number,
        required: true
    },
    currentValue: {
        type: Number,
        required: true
    },
    stressMarked: {
        type: Boolean,
        required: true
    }
});

// returns true if currentValue is under 50% of maxValue
const valueCritical = computed(() => {
    return props.currentValue < props.maxValue * 0.5;
});
</script>

<style scoped>
.attribute-card-border :deep(.rounded-xl){
    border-radius: 0;
}
</style>

<template>
    <!-- wrapper div to center the card and stress card -->
    <div class="flex flex-col items-center attribute-card-border">
        <!-- h-full stretches background color to full height -->
        <Card class="min-w-[150px] h-full" :class="{ 'box-orange': stressMarked, 'pulse-box-red': valueCritical }">
            <template #header>
                <div class="text-center text-2xl mt-6 font-display">
                    {{ attributeTitle }}
                </div>
            </template>
            <template #content>
                <div class="text-center text-6xl font-sans rounded-lg border border-[var(--p-accent-color)] bg-[var(--p-surface-900)] p-2">
                    {{ currentValue }}
                </div>
                <div class="text-xl text-center mt-4 border border-[var(--p-accent-color)] bg-[var(--p-surface-900)] rounded-full max-w-[50px] mx-auto p-1">
                    <span class="font-sans">{{ maxValue }}</span>
                </div>
            </template>
            <template #footer class="text-center">
                <div class="text-center">
                    {{ stressMarked }}
                </div>
            </template>
        </Card>
    </div>
</template>