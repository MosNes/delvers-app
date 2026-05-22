<script setup>
import Card from '@/volt/Card.vue';
import Button from '@/volt/Button.vue';
import Popover from '@/volt/Popover.vue';
import { computed, ref } from 'vue';

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

const tempOverride = ref(0);

const maxValueOverride = computed(() => props.maxValue + tempOverride.value);

const displayedMaxValue = computed(() =>
    tempOverride.value !== 0 ? maxValueOverride.value : props.maxValue
);

const valueCritical = computed(() => {
    return props.currentValue < maxValueOverride.value * 0.5;
});

const emit = defineEmits(['update:stressMarked', 'update:currentValue']);

const valuePopover = ref(null);
const overridePopover = ref(null);

const toggleValuePopover = (event) => {
    valuePopover.value?.toggle(event);
};

const incrementValue = () => {
    if (props.currentValue < maxValueOverride.value) {
        emit('update:currentValue', props.currentValue + 1);
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

const decrementValue = () => {
    if (props.currentValue > 0) {
        emit('update:currentValue', props.currentValue - 1);
    }
};

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
                <!-- click to open popover and adjust current value -->
                <div class="text-center text-6xl font-sans rounded-lg border border-[var(--p-accent-color)] bg-[var(--p-surface-900)] p-2 cursor-pointer"
                    :class="{ 'text-[var(--p-primary-400)]': valueCritical }" @click="toggleValuePopover">
                    {{ currentValue }}
                </div>
                <Popover ref="valuePopover">
                    <div class="flex items-center gap-3">
                        <Button label="-" class="art-deco-frame font-display text-lg" @click="decrementValue" />
                        <span class="text-2xl font-sans min-w-[2ch] text-center">{{ currentValue }}</span>
                        <Button label="+" class="art-deco-frame font-display text-lg" @click="incrementValue" />
                    </div>
                </Popover>
                <div class="mt-4 flex items-center justify-center gap-2">
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
                            <Button label="-" class="art-deco-frame font-display text-lg" @click="decrementOverride" />
                            <span class="text-2xl font-sans min-w-[2ch] text-center">{{ tempOverride }}</span>
                            <Button label="+" class="art-deco-frame font-display text-lg" @click="incrementOverride" />
                        </div>
                        </div>
                        
                    </Popover>
                </div>
            </template>
            <template #footer class="text-center">
                <div class="flex justify-center translate-y-3">
                    <!-- stress button -->
                    <!-- changes color of button when stressMarked is true -->
                    <Button :label="stressMarked ? 'Clear' : 'Stress'" class="art-deco-frame font-display text-lg"
                        :class="stressMarked ? '!bg-[#f58834] hover:!bg-[#e07a2e] !text-[var(--p-surface-900)]' : ''"
                        @click="toggleStress" />
                </div>
            </template>
        </Card>
    </div>
</template>