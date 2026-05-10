<script setup>
import Card from '@/volt/Card.vue';
import Divider from '@/volt/Divider.vue';

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
</script>

<style scoped>
.attribute-card-border :deep(.rounded-xl){
    border-radius: 0;
}
</style>

<template>
    <!-- wrapper div to center the card and stress card -->
    <div class="flex flex-col items-center justify-center attribute-card-border">
        <Card class="min-w-[150px]">
            <template #header>
                <div class="text-center font-bold text-2xl mt-6">
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