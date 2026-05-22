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
                Placeholder
            </template>
        </Card>
    </div>

</template>
