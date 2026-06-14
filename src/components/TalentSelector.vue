<!-- modal for selecting talents and creating talent_instances for a character -->
<script setup>
import { reactive, computed, watch } from 'vue'

import { supabase } from '@/lib/supabaseClient'

import LoadingState from '@/components/LoadingState.vue'
import Dialog from '@/volt/Dialog.vue'
import DataTable from '@/volt/DataTable.vue'
import Column from 'primevue/column'
import Button from '@/volt/Button.vue'
import SecondaryButton from '@/volt/SecondaryButton.vue'
import InputText from '@/volt/InputText.vue'

const props = defineProps({
    characterId: { type: String, required: true },
    visible: { type: Boolean, default: false },
    // names of talents already on the character, used to hide already-added
    // non-repeatable talents from the list
    existingTalentNames: { type: Array, default: () => [] },
})

const emit = defineEmits(['update:visible', 'saved'])

const state = reactive({
    allTalents: [],
    selected: [],
    filters: { global: { value: null, matchMode: 'contains' } },
    saving: false,
    isLoaded: false,
    isError: false,
    saveError: '',
})

// talents the user may still add: repeatable ones, or those not already present
const availableTalents = computed(() =>
    state.allTalents.filter(
        (t) => t.isRepeatable || !props.existingTalentNames.includes(t.name)
    )
)

async function fetchTalents() {
    state.isLoaded = false
    state.isError = false
    try {
        const { data, error } = await supabase
            .from('talents')
            .select('name, type, description, flavorText, path_name, isRepeatable, hasPicklist, picklistValues, picklistHasObj')
            .order('name')

        if (error) throw error

        state.allTalents = data
        state.isLoaded = true
    } catch (err) {
        console.error('Failed to load talents:', err)
        state.isError = true
        state.isLoaded = true
    }
}

// load the talent list the first time the modal is opened
watch(
    () => props.visible,
    (isVisible) => {
        if (isVisible && state.allTalents.length === 0) fetchTalents()
    }
)

function close() {
    state.selected = []
    state.saveError = ''
    emit('update:visible', false)
}

async function save() {
    if (state.selected.length === 0) {
        close()
        return
    }

    state.saving = true
    state.saveError = ''

    // value is a jsonb column capturing the talent's picklist metadata plus the
    // user's eventual selection (selectedValue starts null)
    const rows = state.selected.map((t) => ({
        character_id: props.characterId,
        talent_name: t.name,
        value: {
            path_name: t.path_name,
            type: t.type,
            description: t.description,
            flavorText: t.flavorText,
            hasPicklist: t.hasPicklist,
            picklistValues: t.picklistValues,
            picklistHasObj: t.picklistHasObj,
            selectedValue: null,
        },
    }))

    const { error } = await supabase.from('talent_instances').insert(rows)

    state.saving = false

    if (error) {
        state.saveError = error.message
        return
    }

    state.selected = []
    emit('saved')
    emit('update:visible', false)
}
</script>

<template>
    <Dialog :visible="visible" @update:visible="emit('update:visible', $event)" modal header="Select Talents"
        :style="{ width: '50rem' }" :breakpoints="{ '960px': '90vw' }">

        <LoadingState v-if="!state.isLoaded || state.saving" :is-error="state.isError" />

        <template v-else>
            <DataTable :value="availableTalents" v-model:selection="state.selected" dataKey="name" paginator :rows="25"
                :filters="state.filters" :globalFilterFields="['name', 'type', 'description', 'path_name']" removableSort>
                <template #header>
                    <div class="flex justify-end">
                        <InputText v-model="state.filters['global'].value" placeholder="Search talents" />
                    </div>
                </template>
                <Column selectionMode="multiple" headerStyle="width: 3rem" />
                <Column field="name" header="Name" sortable />
                <Column field="path_name" header="Path" sortable />
                <Column field="type" header="Type" sortable />
                <Column field="description" header="Description" />
            </DataTable>
            <small v-if="state.saveError" class="text-red-500">{{ state.saveError }}</small>
        </template>

        <template #footer>
            <div class="flex justify-end gap-2">
                <SecondaryButton label="Cancel" @click="close" />
                <Button label="Save" :loading="state.saving" :disabled="state.selected.length === 0" @click="save" />
            </div>
        </template>
    </Dialog>
</template>
