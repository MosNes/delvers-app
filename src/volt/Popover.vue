<template>
    <Popover
        unstyled
        :pt="theme"
        :ptOptions="{
            mergeProps: ptViewMerge
        }"
    >
        <template v-for="(_, slotName) in $slots" #[slotName]="slotProps">
            <slot :name="slotName" v-bind="slotProps ?? {}" />
        </template>
    </Popover>
</template>

<script setup lang="ts">
import Popover, { type PopoverPassThroughOptions, type PopoverProps } from 'primevue/popover';
import { ref } from 'vue';
import { ptViewMerge } from './utils';

interface Props extends /* @vue-ignore */ PopoverProps {}
defineProps<Props>();

const theme = ref<PopoverPassThroughOptions>({
    root: `border-2 border-[var(--p-accent-color)] rounded-md bg-[var(--p-surface-900)] text-[var(--p-text-color)] shadow-[6px_6px_4px_rgba(0,0,0,0.35)]`,
    content: `p-2`
});
</script>
