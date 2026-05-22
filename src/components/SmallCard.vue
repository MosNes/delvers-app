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

const tempOverride = ref(0);

const maxValueOverride = computed(() => props.maxValue + tempOverride.value);

const displayedMaxValue = computed(() => {
    const raw = tempOverride.value !== 0 ? maxValueOverride.value : props.maxValue;
    return Math.min(20, Math.max(0, raw));
});

const valueCritical = computed(() => {
    return props.hasMaxValue && props.value < maxValueOverride.value * 0.5;
});

const valuePopover = ref(null);
const overridePopover = ref(null);

const toggleValuePopover = (event) => {
    valuePopover.value?.toggle(event);
};

const incrementValue = () => {
    const next = props.value + 1;
    if (props.hasMaxValue && next > maxValueOverride.value) return;
    emit('update:value', next);
};

const decrementValue = () => {
    if (props.value > 0) {
        emit('update:value', props.value - 1);
    }
};

const toggleOverridePopover = (event) => {
    overridePopover.value?.toggle(event);
};

const incrementOverride = () => {
    if (tempOverride.value < 20) {
        tempOverride.value += 1;
    }
};

const decrementOverride = () => {
    if (tempOverride.value > -20) {
        tempOverride.value -= 1;
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
                <div v-if="hasMaxValue" class="mt-2 flex items-center justify-center gap-2 mb-12">
                    <div
                        class="text-xl text-center border border-[var(--p-accent-color)] bg-[var(--p-surface-900)] rounded-full max-w-[50px] min-w-[50px] p-1"
                        :class="{ 'box-orange': tempOverride !== 0 }">
                        <span class="font-sans">{{ displayedMaxValue }}</span>
                    </div>
                    <Button label="±" class="art-deco-frame font-display text-lg shrink-0"
                        @click="toggleOverridePopover" />
                    <Popover ref="overridePopover">
                        <div class="flex flex-col items-center">
                            <div class="text-center p-1">
                                <p>Override Max Value</p>
                            </div>
                            <div class="flex items-center gap-3">
                                <Button label="-" class="art-deco-frame font-display text-lg"
                                    @click="decrementOverride" />
                                <span class="text-2xl font-sans min-w-[2ch] text-center">{{ tempOverride }}</span>
                                <Button label="+" class="art-deco-frame font-display text-lg"
                                    @click="incrementOverride" />
                            </div>
                        </div>
                    </Popover>
                </div>
            </template>
        </Card>
    </div>

</template>
