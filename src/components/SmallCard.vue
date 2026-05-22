<script setup>
import Card from '@/volt/Card.vue';
import Button from '@/volt/Button.vue';
import Popover from '@/volt/Popover.vue';
import { computed, ref } from 'vue';

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

const emit = defineEmits(['update:value']);

const valueCritical = computed(() => {
    return props.hasMaxValue && props.value < props.maxValue * 0.5;
});

const valuePopover = ref(null);

const toggleValuePopover = (event) => {
    valuePopover.value?.toggle(event);
};

const incrementValue = () => {
    const next = props.value + 1;
    if (props.hasMaxValue && next > props.maxValue) return;
    emit('update:value', next);
};

const decrementValue = () => {
    if (props.value > 0) {
        emit('update:value', props.value - 1);
    }
};

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
                <div
                    class="text-center text-4xl font-sans rounded-lg border border-[var(--p-accent-color)] bg-[var(--p-surface-900)] p-2 cursor-pointer"
                    :class="{ 'text-[var(--p-primary-400)]': valueCritical }"
                    @click="toggleValuePopover">
                    {{ value }}
                </div>
                <Popover ref="valuePopover">
                    <div class="flex items-center gap-3">
                        <Button label="-" class="art-deco-frame font-display text-lg" @click="decrementValue" />
                        <span class="text-2xl font-sans min-w-[2ch] text-center">{{ value }}</span>
                        <Button label="+" class="art-deco-frame font-display text-lg" @click="incrementValue" />
                    </div>
                </Popover>
                <div v-if="hasMaxValue"
                    class="text-xl text-center mt-2 border border-[var(--p-accent-color)] bg-[var(--p-surface-900)] rounded-full max-w-[50px] mx-auto mb-5">
                    <span class="font-sans">{{ maxValue }}</span>
                </div>
            </template>
        </Card>
    </div>

</template>
