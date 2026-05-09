<script setup>
import Card from '@/volt/Card.vue';

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
    <Card>
        <template #header>
            {{ attributeTitle }}
        </template>
        <template #content>
            {{  currentValue  }}
        </template>
        <template #footer>
            {{  maxValue }}
        </template>
    </Card>
    <Card>
        <template #content>
            {{  stressMarked  }}
        </template>
    </Card>
</template>