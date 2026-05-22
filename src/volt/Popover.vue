<template>
    <Popover ref="popover" unstyled :pt="theme" :ptOptions="{
        mergeProps: ptViewMerge
    }">
        <template v-for="(_, slotName) in $slots" #[slotName]="slotProps">
            <slot :name="slotName" v-bind="slotProps ?? {}" />
        </template>
    </Popover>
</template>

<script setup lang="ts">
import Popover, { type PopoverPassThroughOptions, type PopoverProps } from 'primevue/popover';
import { ref } from 'vue';
import { ptViewMerge } from './utils';

interface Props extends /* @vue-ignore */ PopoverProps { }
defineProps<Props>();

const popover = ref<InstanceType<typeof Popover> | null>(null);

defineExpose({
    toggle: (event: Event, target?: HTMLElement) => popover.value?.toggle(event, target),
    show: (event: Event, target?: HTMLElement) => popover.value?.show(event, target),
    hide: () => popover.value?.hide()
});

const theme = ref<PopoverPassThroughOptions>({
    root: `border-2 border-[var(--p-accent-color)] rounded-md bg-[var(--p-surface-900)] text-[var(--p-text-color)] shadow-[6px_6px_4px_rgba(0,0,0,0.35)]`,
    content: `p-2`
});
</script>
