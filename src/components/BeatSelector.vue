<!-- modal for selecting a single beat belonging to a character's destiny -->
<script setup>
import { reactive, watch } from 'vue'

import { supabase } from '@/lib/supabaseClient'

import LoadingState from '@/components/LoadingState.vue'
import Dialog from '@/volt/Dialog.vue'
import DataTable from '@/volt/DataTable.vue'
import Column from 'primevue/column'
import Button from '@/volt/Button.vue'
import SecondaryButton from '@/volt/SecondaryButton.vue'

const props = defineProps({
    destiny: { type: String, default: null }, // destiny name (destiny_tracker.destiny)
    visible: { type: Boolean, default: false },
})

const emit = defineEmits(['update:visible', 'selected'])

const state = reactive({
    items: [],
    isLoaded: false,
    isError: false,
})

async function fetchBeats() {
    state.isLoaded = false
    state.isError = false
    try {
        // beats.destiny_id → destinies(id); the character's destiny is stored by name,
        // so join through destinies and filter on its name.
        const { data, error } = await supabase
            .from('beats')
            .select('id, type, description, destinies!inner(name)')
            .eq('destinies.name', props.destiny)
            .order('type')

        if (error) throw error

        state.items = (data ?? []).map(({ id, type, description }) => ({ id, type, description }))
        state.isLoaded = true
    } catch (err) {
        console.error('Failed to load beats:', err)
        state.isError = true
        state.isLoaded = true
    }
}

// load when the modal opens
watch(
    () => props.visible,
    (isVisible) => {
        if (isVisible) fetchBeats()
    }
)

// reload if the destiny changes while open
watch(
    () => props.destiny,
    () => {
        if (props.visible) fetchBeats()
    }
)

function select(beat) {
    emit('selected', beat)
    emit('update:visible', false)
}
</script>

<template>
    <Dialog :visible="visible" @update:visible="emit('update:visible', $event)" modal header="Select Beat"
        :style="{ width: '50rem' }" :breakpoints="{ '960px': '90vw' }">

        <LoadingState v-if="!state.isLoaded" :is-error="state.isError" />

        <template v-else>
            <DataTable :value="state.items" dataKey="id" paginator :rows="25" removableSort>
                <Column field="type" header="Type" sortable />
                <Column field="description" header="Description" />
                <Column header="" headerStyle="width: 8rem">
                    <template #body="{ data }">
                        <Button type="button" label="Select" @click="select(data)" />
                    </template>
                </Column>
            </DataTable>
        </template>

        <template #footer>
            <div class="flex justify-end">
                <SecondaryButton type="button" label="Cancel" @click="emit('update:visible', false)" />
            </div>
        </template>
    </Dialog>
</template>
