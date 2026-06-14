<!-- a small self-anchored popover that indicates an in-flight save (or a save error) -->
<script setup>
import { ref } from 'vue'

import Popover from '@/volt/Popover.vue'
import ProgressSpinner from '@/volt/ProgressSpinner.vue'

defineProps({
    isError: { type: Boolean, default: false },
    errorMessage: { type: String, default: '' },
})

const popover = ref(null)
const anchor = ref(null)

// PrimeVue Popover anchors to a target element, so the component owns its own
// anchor and exposes simple show()/hide() controls for the parent to drive.
defineExpose({
    show: () => popover.value?.show({ currentTarget: anchor.value }, anchor.value),
    hide: () => popover.value?.hide(),
})
</script>

<template>
    <span ref="anchor" class="fixed bottom-4 right-4 z-50" aria-hidden="true"></span>

    <Popover ref="popover">
        <div class="flex items-center gap-3">
            <template v-if="isError">
                <span class="text-red-500">{{ errorMessage || 'Save failed.' }}</span>
            </template>
            <template v-else>
                <div class="w-6 h-6">
                    <ProgressSpinner class="w-6! h-6!" />
                </div>
                <span>Saving…</span>
            </template>
        </div>
    </Popover>
</template>
