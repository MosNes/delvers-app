<!-- free-text multi-value entry: type a value and tap Add (or press Enter) to append a chip. -->
<!-- Mobile-friendly: the Add button means it does NOT depend on the Enter key, since not -->
<!-- all mobile keyboards emit one. v-model is an array of strings. -->
<script setup>
import { ref } from 'vue'

import InputText from '@/volt/InputText.vue'
import Button from '@/volt/Button.vue'

const props = defineProps({
    modelValue: { type: Array, default: () => [] },
    placeholder: { type: String, default: '' },
    inputId: { type: String, default: undefined },
})

const emit = defineEmits(['update:modelValue'])

const draft = ref('')

function add() {
    const value = draft.value.trim()
    if (!value) return
    // ignore duplicates, but still clear the field
    if (!props.modelValue.includes(value)) {
        emit('update:modelValue', [...props.modelValue, value])
    }
    draft.value = ''
}

function remove(index) {
    const next = props.modelValue.slice()
    next.splice(index, 1)
    emit('update:modelValue', next)
}
</script>

<template>
    <div class="flex flex-col gap-2">
        <div class="flex gap-2">
            <!-- @keyup.enter is a convenience for desktop; the Add button is the reliable path -->
            <InputText :id="inputId" v-model="draft" :placeholder="placeholder" fluid @keyup.enter="add" />
            <Button type="button" label="Add" icon="pi pi-plus"class="art-deco-frame font-display" @click="add" />
        </div>
        <ul v-if="modelValue.length" class="flex flex-wrap gap-1 list-none m-0 p-0">
            <li v-for="(item, i) in modelValue" :key="`${item}-${i}`"
                class="inline-flex items-center gap-2 rounded-sm px-3 py-1 bg-surface-100 dark:bg-surface-800 text-surface-800 dark:text-surface-0">
                <span>{{ item }}</span>
                <button type="button" :aria-label="`Remove ${item}`" class="cursor-pointer leading-none"
                    @click="remove(i)">
                    <i class="pi pi-times text-xs"></i>
                </button>
            </li>
        </ul>
    </div>
</template>
