<!-- modal for selecting a single beat belonging to a character's destiny -->
<script setup>
import { reactive, computed, watch } from 'vue'

import { supabase } from '@/lib/supabaseClient'

import LoadingState from '@/components/LoadingState.vue'
import Dialog from '@/volt/Dialog.vue'
import DataTable from '@/volt/DataTable.vue'
import Column from 'primevue/column'
import Button from '@/volt/Button.vue'
import SecondaryButton from '@/volt/SecondaryButton.vue'
import Select from '@/volt/Select.vue'

const props = defineProps({
    destinyId: { type: String, default: null }, // destiny_tracker.destiny_id
    visible: { type: Boolean, default: false },
})

const emit = defineEmits(['update:visible', 'selected'])

// beats.type is constrained to these values in the DB (postgresSchema.sql)
const BEAT_TYPES = ['Minor', 'Major', 'Pinnacle']

const state = reactive({
    items: [],
    typeFilter: null,
    isLoaded: false,
    isError: false,
})

const filteredBeats = computed(() =>
    state.typeFilter
        ? state.items.filter((b) => b.type === state.typeFilter)
        : state.items
)

async function fetchBeats() {
    state.isLoaded = false
    state.isError = false
    state.typeFilter = null
    try {
        // beats.destiny_id → destinies(id); filter directly by the character's destiny_id.
        const { data, error } = await supabase
            .from('beats')
            .select('id, type, description')
            .eq('destiny_id', props.destinyId)
            .order('type')

        if (error) throw error

        state.items = data ?? []
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
    () => props.destinyId,
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
            <DataTable :value="filteredBeats" dataKey="id" paginator :rows="25" removableSort>
                <template #header>
                    <div class="flex justify-end">
                        <Select v-model="state.typeFilter" :options="BEAT_TYPES"
                            placeholder="Filter by type" showClear />
                    </div>
                </template>
                <Column field="type" header="Type" sortable />
                <Column field="description" header="Description" />
                <Column header="" headerStyle="width: 8rem">
                    <template #body="{ data }">
                        <Button type="button" label="Select" @click="select(data)" class="art-deco-frame font-display text-lg" />
                    </template>
                </Column>
            </DataTable>
        </template>

        <template #footer>
            <div class="flex justify-end">
                <Button type="button" label="Cancel" @click="emit('update:visible', false)" class="art-deco-frame font-display text-lg" />
            </div>
        </template>
    </Dialog>
</template>
