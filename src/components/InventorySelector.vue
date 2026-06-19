<!-- modal for selecting items and creating inventory_instances for a character -->
<script setup>
import { reactive, watch } from 'vue'

import { supabase } from '@/lib/supabaseClient'

import LoadingState from '@/components/LoadingState.vue'
import Dialog from '@/volt/Dialog.vue'
import DataTable from '@/volt/DataTable.vue'
import Column from 'primevue/column'
import Button from '@/volt/Button.vue'
import SecondaryButton from '@/volt/SecondaryButton.vue'
import InputText from '@/volt/InputText.vue'
import Select from '@/volt/Select.vue'

const props = defineProps({
    characterId: { type: String, required: true },
    visible: { type: Boolean, default: false },
})

const emit = defineEmits(['update:visible', 'saved'])

// itemType (the singular CHECK value stored on the instance) -> source table name
const TYPE_TABLE = {
    gear: 'gear',
    armor: 'armor',
    weapon: 'weapons',
    curio: 'curios',
    artifact: 'artifacts',
}

// build the default item_config jsonb for a newly-created inventory instance
// from the selected base item; see "Inventory Instances Data Model" in CLAUDE.md
function buildItemConfig(item, itemType) {
    return {
        name: item.name,
        dmg: itemType === 'weapon' ? (item.baseDmg ?? null) : null,
        description: item.description ?? null,
        effect: item.effect ?? null,
        stackValue: item.stack != null ? Math.max(1, item.stack) : 1,
        armor:
            itemType === 'armor' ? (item.armor_value ?? 0)
            : itemType === 'weapon' ? (item.armor ?? 0)
            : 0,
        hasClock: item.hasClock ?? false,
        clockValue: item.clockValue ?? 0,
        slots: item.slots ?? 0,
    }
}

const typeOptions = [
    { label: 'Gear', value: 'gear' },
    { label: 'Armor', value: 'armor' },
    { label: 'Weapon', value: 'weapon' },
    { label: 'Curio', value: 'curio' },
    { label: 'Artifact', value: 'artifact' },
]

const state = reactive({
    itemType: 'gear',
    items: [],
    selected: [],
    filters: { global: { value: null, matchMode: 'contains' } },
    saving: false,
    isLoaded: false,
    isError: false,
    saveError: '',
})

async function fetchItems() {
    state.isLoaded = false
    state.isError = false
    state.selected = []
    try {
        const { data, error } = await supabase
            .from(TYPE_TABLE[state.itemType])
            .select('*')
            .order('name')

        if (error) throw error

        state.items = data
        state.isLoaded = true
    } catch (err) {
        console.error('Failed to load items:', err)
        state.isError = true
        state.isLoaded = true
    }
}

// load the first time the modal opens
watch(
    () => props.visible,
    (isVisible) => {
        if (isVisible && !state.isLoaded) fetchItems()
    }
)

// reload the list when the type picker changes
watch(
    () => state.itemType,
    () => {
        if (props.visible) fetchItems()
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

    const rows = state.selected.map((item) => ({
        character_id: props.characterId,
        itemType: state.itemType,
        baseItem: item.id,
        displayName: item.name,
        item_config: buildItemConfig(item, state.itemType),
    }))

    const { error } = await supabase.from('inventory_instances').insert(rows)

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
    <Dialog :visible="visible" @update:visible="emit('update:visible', $event)" modal header="Add Inventory"
        :style="{ width: '50rem' }" :breakpoints="{ '960px': '90vw' }">

        <div class="flex flex-col gap-1 mb-4 max-w-xs">
            <label for="itemType" class="text-sm font-medium">Item Type</label>
            <Select id="itemType" v-model="state.itemType" :options="typeOptions" optionLabel="label"
                optionValue="value" fluid />
        </div>

        <LoadingState v-if="!state.isLoaded || state.saving" :is-error="state.isError" />

        <template v-else>
            <DataTable :value="state.items" v-model:selection="state.selected" dataKey="id" paginator :rows="25"
                :filters="state.filters" :globalFilterFields="['name', 'description']" removableSort>
                <template #header>
                    <div class="flex justify-end">
                        <InputText v-model="state.filters['global'].value" placeholder="Search items" />
                    </div>
                </template>
                <Column selectionMode="multiple" headerStyle="width: 3rem" />
                <Column field="name" header="Name" sortable />
                <Column field="slots" header="Slots" sortable />
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
