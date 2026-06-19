<!-- editable view of a single inventory instance, shown inside the inventory accordion content -->
<script setup>
import { reactive } from 'vue'

import { supabase } from '@/lib/supabaseClient'

import LoadingState from '@/components/LoadingState.vue'
import Card from '@/volt/Card.vue'
import Button from '@/volt/Button.vue'
import SecondaryButton from '@/volt/SecondaryButton.vue'
import DangerButton from '@/volt/DangerButton.vue'
import InputText from '@/volt/InputText.vue'
import InputNumber from '@/volt/InputNumber.vue'
import Textarea from '@/volt/Textarea.vue'
import ToggleSwitch from '@/volt/ToggleSwitch.vue'

const props = defineProps({
    id: { type: String, required: true }, // inventory_instances.id — needed for the DB write
    item_config: { type: Object, required: true },
})

const emit = defineEmits(['saved', 'remove'])

// per the user's instruction: item_config as a reactive object
const itemConfig = reactive({ ...props.item_config })

const ui = reactive({ editing: false, busy: false, isError: false, errorMessage: '' })

// backup so Cancel can revert without touching the DB
let snapshot = null

// full-width fields rendered above the card grid
const TOP_FIELDS = [
    { key: 'name', label: 'Name', type: 'text' },
    { key: 'description', label: 'Description', type: 'textarea' },
    { key: 'effect', label: 'Effect', type: 'textarea' },
]

// each entry is a card; type picks the editor used in edit mode
const CARDS = [
    [
        { key: 'dmg', label: 'Damage', type: 'text' },
        { key: 'slots', label: 'Slots', type: 'number', min: 0 },
    ],
    [
        { key: 'armor', label: 'Armor', type: 'number', min: 0 },
        { key: 'stackValue', label: 'Items Remaining', type: 'number', min: 1 },
    ],
    [
        { key: 'hasClock', label: 'Reusable', type: 'boolean' },
        { key: 'clockValue', label: 'Uses Remaining', type: 'number', min: 0 },
    ],
]

function formatValue(field, val) {
    if (field.type === 'boolean') return val ? 'Yes' : 'No'
    if (val === null || val === undefined || val === '') return '—'
    return val
}

function startEdit() {
    snapshot = JSON.parse(JSON.stringify(itemConfig))
    ui.editing = true
}

function cancel() {
    Object.assign(itemConfig, snapshot)
    ui.isError = false
    ui.errorMessage = ''
    ui.editing = false
}

async function save() {
    ui.busy = true
    ui.isError = false
    ui.errorMessage = ''
    try {
        const { error } = await supabase
            .from('inventory_instances')
            .update({ item_config: { ...itemConfig }, displayName: itemConfig.name })
            .eq('id', props.id)

        if (error) throw error

        ui.editing = false
        emit('saved') // parent refetches → accordion header reflects the new name
    } catch (err) {
        ui.isError = true
        ui.errorMessage = err.message
    } finally {
        ui.busy = false
    }
}

function remove() {
    emit('remove', props.id)
}
</script>

<template>
    <div class="art-deco-frame p-3 text-lg">
        <LoadingState v-if="ui.busy" :is-error="ui.isError" :error-message="ui.errorMessage" />
        <template v-else>
            <main class="p-4">
                <!-- full-width fields -->
                <div v-for="field in TOP_FIELDS" :key="field.key" class="mb-2">
                    <div class="text-md text-gray-400 font-display">{{ field.label }}</div>
                    <template v-if="ui.editing">
                        <InputText v-if="field.type === 'text'" v-model="itemConfig[field.key]" fluid />
                        <Textarea v-else-if="field.type === 'textarea'" v-model="itemConfig[field.key]" rows="2"
                            fluid />
                    </template>
                    <div v-else>{{ formatValue(field, itemConfig[field.key]) }}</div>
                </div>

                <!-- 3-card grid: 1 column on small screens, 3 columns at md+ -->
                <div class="flex flex-col md:flex-row gap-5 mt-3">
                    <div v-for="(card, i) in CARDS" :key="i" class="flex-1">
                        <Card>
                            <template #content>
                                <div v-for="field in card" :key="field.key" class="mb-2">
                                    <div class="text-md text-gray-400 font-display">{{ field.label }}</div>
                                    <template v-if="ui.editing">
                                        <InputText v-if="field.type === 'text'" v-model="itemConfig[field.key]" fluid />
                                        <InputNumber v-else-if="field.type === 'number'" v-model="itemConfig[field.key]"
                                            :min="field.min" fluid />
                                        <ToggleSwitch v-else-if="field.type === 'boolean'"
                                            v-model="itemConfig[field.key]" />
                                    </template>
                                    <div v-else>{{ formatValue(field, itemConfig[field.key]) }}</div>
                                </div>
                            </template>
                        </Card>
                    </div>
                </div>

                <small v-if="ui.isError" class="text-red-500">{{ ui.errorMessage }}</small>

                <div class="flex justify-end gap-2 mt-3">
                    <template v-if="ui.editing">
                        <SecondaryButton type="button" label="Cancel" @click="cancel" />
                        <Button type="button" label="Save" :loading="ui.busy" @click="save" />
                    </template>
                    <template v-else>
                        <Button type="button" label="Edit" icon="pi pi-pencil" @click="startEdit" />
                        <DangerButton type="button" label="Remove" @click="remove" />
                    </template>
                </div>
            </main>

        </template>
    </div>
</template>
