<!-- modal for randomly generating a curio or artifact and adding it to a character's inventory -->
<script setup>
import { reactive, computed, watch } from 'vue'

import { supabase } from '@/lib/supabaseClient'

import Dialog from '@/volt/Dialog.vue'
import Select from '@/volt/Select.vue'
import Button from '@/volt/Button.vue'
import SecondaryButton from '@/volt/SecondaryButton.vue'

const props = defineProps({
    characterId: { type: String, required: true },
    visible: { type: Boolean, default: false },
    itemType: { type: String, default: 'curio' }, // 'curio' | 'artifact'
})

const emit = defineEmits(['update:visible', 'saved'])

// itemType -> source table name
const TYPE_TABLE = { curio: 'curios', artifact: 'artifacts' }
const SOURCES = ['All Sources', 'Ancient Magitech', 'Prototype Magitech', 'Divine', 'Nightmare', 'Void']

// state.result holds the picked row and drives the summary modal (visible when non-null)
const state = reactive({ source: 'All Sources', generating: false, error: '', result: null })

const headerLabel = computed(() => (props.itemType === 'artifact' ? 'Random Artifact' : 'Random Curio'))

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
        hasDepletion: item.hasDepletion ?? false,
        depletionDie: item.depletionDie ?? null,
        depletionResult: item.depletionResult ?? null,
    }
}

async function generate() {
    state.generating = true
    state.error = ''
    try {
        let query = supabase.from(TYPE_TABLE[props.itemType]).select('*')
        if (state.source !== 'All Sources') query = query.eq('source', state.source)
        const { data, error } = await query
        if (error) throw error
        if (!data?.length) {
            state.error = 'No items match that source.'
            return
        }

        const pick = data[Math.floor(Math.random() * data.length)]
        const { error: insertError } = await supabase.from('inventory_instances').insert({
            character_id: props.characterId,
            itemType: props.itemType,
            baseItem: pick.id,
            displayName: pick.name,
            item_config: buildItemConfig(pick, props.itemType),
        })
        if (insertError) throw insertError

        emit('saved')                 // parent refetches inventory underneath
        state.result = pick           // success -> show summary modal
        emit('update:visible', false) // close the selector dialog behind the summary
    } catch (err) {
        console.error('Failed to generate item:', err)
        state.error = err.message
    } finally {
        state.generating = false
    }
}

function cancel() {
    state.error = ''
    emit('update:visible', false)
}

// closes the summary modal after the user reviews the generated item
function closeSummary() {
    state.result = null
}

// reset filter/error/result whenever the selector dialog opens
watch(
    () => props.visible,
    (isVisible) => {
        if (isVisible) {
            state.source = 'All Sources'
            state.error = ''
            state.result = null
        }
    }
)
</script>

<template>
    <Dialog :visible="visible" @update:visible="emit('update:visible', $event)" modal :header="headerLabel"
        :style="{ width: '32rem' }" :breakpoints="{ '960px': '90vw' }">

        <div class="flex flex-col gap-1 max-w-xs">
            <label for="source" class="text-sm font-medium">Source</label>
            <Select id="source" v-model="state.source" :options="SOURCES" placeholder="Select a source" fluid />
        </div>

        <small v-if="state.error" class="text-red-500">{{ state.error }}</small>

        <template #footer>
            <div class="flex justify-end gap-2">
                <SecondaryButton label="Cancel" @click="cancel" />
                <Button label="Generate" :loading="state.generating" @click="generate" />
            </div>
        </template>
    </Dialog>

    <!-- summary of the generated item; opens on successful generate() -->
    <Dialog :visible="!!state.result" @update:visible="closeSummary" modal header="Item Generated"
        :style="{ width: '32rem' }" :breakpoints="{ '960px': '90vw' }">
        <div v-if="state.result" class="flex flex-col gap-3">
            <div>
                <div class="text-gray-400 font-display">Name</div>
                <div>{{ state.result.name }}</div>
            </div>
            <div>
                <div class="text-gray-400 font-display">Source</div>
                <div>{{ state.result.source || '--' }}</div>
            </div>
            <div>
                <div class="text-gray-400 font-display">Description</div>
                <div>{{ state.result.description || '--' }}</div>
            </div>
            <div>
                <div class="text-gray-400 font-display">Effect</div>
                <div>{{ state.result.effect || '--' }}</div>
            </div>
        </div>
        <template #footer>
            <div class="flex justify-end">
                <Button label="Close" @click="closeSummary" />
            </div>
        </template>
    </Dialog>
</template>
