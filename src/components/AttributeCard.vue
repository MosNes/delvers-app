<script setup>
import Card from '@/volt/Card.vue';
import Button from '@/volt/Button.vue';
import { computed, defineEmits } from 'vue';

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


// allows parent component to update stressMarked value
const emit = defineEmits(['update:stressMarked']);

const toggleStress = () => {
    emit('update:stressMarked', !props.stressMarked);
};


</script>

<style scoped>
.attribute-card-border :deep(.rounded-xl) {
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
                <!-- current value changes color to red when valueCritical is true -->
                <div
                    class="text-center text-6xl font-sans rounded-lg border border-[var(--p-accent-color)] bg-[var(--p-surface-900)] p-2"
                    :class="{ 'text-[var(--p-primary-400)]': valueCritical }">
                    {{ currentValue }}
                </div>
                <div
                    class="text-xl text-center mt-4 border border-[var(--p-accent-color)] bg-[var(--p-surface-900)] rounded-full max-w-[50px] mx-auto p-1">
                    <span class="font-sans">{{ maxValue }}</span>
                </div>
            </template>
            <template #footer class="text-center">
                <div class="flex justify-center translate-y-3">
                    <!-- stress button -->
                     <!-- changes color of button when stressMarked is true -->
                    <Button :label="stressMarked ? 'Clear' : 'Stress'" class="art-deco-frame font-display text-lg"
                        :class="stressMarked ? '!bg-[#f58834] hover:!bg-[#e07a2e] !text-[var(--p-surface-900)]' : ''" @click="toggleStress" />
                </div>
            </template>
        </Card>
    </div>
</template>