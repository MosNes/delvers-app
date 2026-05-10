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

<template>
    <!-- wrapper div to center the card and stress card -->
    <div class="flex flex-col items-center justify-center">
        <Card class="min-w-[150px]">
            <template #header>
                <div class="text-center font-bold text-2xl mt-4">
                    {{ attributeTitle }}
                </div>
            </template>
            <template #content>
                <div class="text-center text-6xl font-bold">
                    {{ currentValue }}
                </div>
                <div class="text-lg text-center mt-4">
                    Max: {{ maxValue }}
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