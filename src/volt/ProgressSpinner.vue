<template>
    <ProgressSpinner
        unstyled
        :pt="theme"
        :ptOptions="{
            mergeProps: ptViewMerge
        }"
    >
        <template v-for="(_, slotName) in $slots" #[slotName]="slotProps">
            <slot :name="slotName" v-bind="slotProps ?? {}" />
        </template>
    </ProgressSpinner>
</template>

<script setup lang="ts">
import ProgressSpinner from 'primevue/progressspinner';
import { ref } from 'vue';
import { ptViewMerge } from './utils';

const theme = ref({
    root: `relative mx-auto w-12 h-12`,
    spin: `volt-progressspinner-spin`,
    circle: `volt-progressspinner-circle`
});
</script>

<style>
@keyframes volt-progressspinner-rotate {
    100% {
        transform: rotate(360deg);
    }
}

@keyframes volt-progressspinner-dash {
    0%   { stroke-dasharray: 1, 200;  stroke-dashoffset: 0;      }
    50%  { stroke-dasharray: 89, 200; stroke-dashoffset: -35px;  }
    100% { stroke-dasharray: 89, 200; stroke-dashoffset: -124px; }
}

.volt-progressspinner-spin {
    transform-origin: center center;
    width: 100%;
    height: 100%;
    position: absolute;
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
    margin: auto;
    animation: volt-progressspinner-rotate 2s linear infinite;
}

.volt-progressspinner-circle {
    stroke-dasharray: 89, 200;
    stroke-dashoffset: 0;
    stroke-linecap: round;
    stroke-width: 3;
    stroke: var(--p-primary-color);
    animation: volt-progressspinner-dash 1.5s ease-in-out infinite;
}
</style>
