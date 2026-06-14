<!-- the edit character view allows the user to edit the character sheet for a character -->
<!-- Additionally the user can create new characters -->
<script setup>
import { reactive, ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import { supabase } from '@/lib/supabaseClient'
import { useAuth } from '@/composables/useAuth'

import LoadingState from '@/components/LoadingState.vue'
import Panel from '@/volt/Panel.vue'
import Button from '@/volt/Button.vue'
import SecondaryButton from '@/volt/SecondaryButton.vue'
import InputText from '@/volt/InputText.vue'
import InputNumber from '@/volt/InputNumber.vue'
import Select from '@/volt/Select.vue'
import Textarea from '@/volt/Textarea.vue'
import AutoComplete from '@/volt/AutoComplete.vue'
import DataTable from '@/volt/DataTable.vue'
import Column from 'primevue/column'
import DangerButton from '@/volt/DangerButton.vue'
import TalentSelector from '@/components/TalentSelector.vue'

const route = useRoute()
const router = useRouter()
const { user } = useAuth()

// Editable fields only. Excluded: id, owner (auto), campaign, doom, blessings,
// curses, all current* values, and the *Stress tracks — those are runtime
// character state, not edited here. Each key maps to a characters table column.
const form = reactive({
    imgUrl: '',
    characterName: '',
    player: '',
    ancestry: '',
    ancestrySpecies: '',
    path: '',
    background: '',
    domains: [],
    skills: [],
    advances: '',
    minorAdvances: 0,
    majorAdvances: 0,
    pinnacleAdvances: 0,
    maxGuard: 0,
    armor: 0,
    maxBody: 0,
    maxSpeed: 0,
    maxMind: 0,
    maxSpirit: 0,
    notes: '',
})

// path picklist options, sourced from the paths table
const paths = ref([])

// isNew is true when creating (no :id route param), false when editing
const dataState = reactive({
    isLoaded: false,
    isError: false,
    errorMessage: '',
    isNew: route.name === 'new-character',
})
const saving = ref(false)
const saveError = ref('')

// required fields (NOT NULL / FK columns) — Save is blocked until all have a value
const REQUIRED = ['characterName', 'player', 'ancestry', 'ancestrySpecies', 'path']
const isFormValid = computed(() => REQUIRED.every((key) => String(form[key]).trim() !== ''))

// talent instances shown in the Talents panel (single reactive state object)
const talentState = reactive({ instances: [], busy: false, selectorVisible: false })

async function fetchTalentInstances() {
    const { data, error } = await supabase
        .from('talent_instances')
        .select('id, value, talents(name, type, description)')
        .eq('character_id', route.params.id)

    if (error) throw error
    talentState.instances = data
}

async function removeTalentInstance(id) {
    talentState.busy = true
    try {
        const { error } = await supabase.from('talent_instances').delete().eq('id', id)
        if (error) throw error
        await fetchTalentInstances()
    } catch (err) {
        console.error('Failed to remove talent:', err)
    } finally {
        talentState.busy = false
    }
}

async function onTalentsSaved() {
    talentState.selectorVisible = false
    talentState.busy = true
    try {
        await fetchTalentInstances()
    } catch (err) {
        console.error('Failed to refresh talents:', err)
    } finally {
        talentState.busy = false
    }
}

onMounted(async () => {
    try {
        if (dataState.isNew) {
            // enforce the 5-character cap before showing a blank form
            const { count, error: countError } = await supabase
                .from('characters')
                .select('id', { count: 'exact', head: true })
                .eq('owner', user.value?.id)

            if (countError) throw countError

            if (count >= 5) {
                dataState.errorMessage = 'Sorry, you are limited to 5 characters total.'
                dataState.isError = true
                dataState.isLoaded = true
                return
            }

            // only the path picklist is needed for a new (blank) character
            const { data: pathsData, error: pathsError } = await supabase
                .from('paths').select('name').eq('isAncestry', false).order('name')
            if (pathsError) throw pathsError

            paths.value = pathsData
            dataState.isLoaded = true
            return
        }

        const [charResult, pathsResult] = await Promise.all([
            supabase.from('characters').select('*').eq('id', route.params.id).single(),
            supabase.from('paths').select('name').eq('isAncestry', false).order('name'),
            fetchTalentInstances(),
        ])

        if (charResult.error) throw charResult.error
        if (pathsResult.error) throw pathsResult.error

        const data = charResult.data
        // copy each editable column into the form; arrays default to [] when null
        for (const key of Object.keys(form)) {
            if (data[key] === null || data[key] === undefined) continue
            form[key] = data[key]
        }

        paths.value = pathsResult.data
        dataState.isLoaded = true
    } catch (err) {
        console.error('Failed to load character for editing:', err)
        dataState.isError = true
        dataState.isLoaded = true
    }
})

async function saveCharacter() {
    // defensive guard — Save is already disabled while invalid
    if (!isFormValid.value) return

    saving.value = true
    saveError.value = ''

    try {
        // owner is set from the logged-in user rather than being an editable field
        if (dataState.isNew) {
            const { data, error } = await supabase
                .from('characters')
                .insert({ ...form, owner: user.value?.id })
                .select('id')
                .single()

            if (error) throw error
            router.push({ name: 'character', params: { id: data.id } })
        } else {
            const { error } = await supabase
                .from('characters')
                .update({ ...form, owner: user.value?.id })
                .eq('id', route.params.id)

            if (error) throw error
            router.push({ name: 'character', params: { id: route.params.id } })
        }
    } catch (err) {
        saveError.value = err.message
    } finally {
        saving.value = false
    }
}

function cancel() {
    if (dataState.isNew) {
        router.push({ name: 'dashboard' })
    } else {
        router.push({ name: 'character', params: { id: route.params.id } })
    }
}
</script>

<template>
    <LoadingState v-if="!dataState.isLoaded || dataState.isError" :is-error="dataState.isError"
        :error-message="dataState.errorMessage" class="min-h-screen" />

    <form v-else class="p-6 flex flex-col gap-6 max-w-4xl mx-auto" @submit.prevent="saveCharacter">

        <h1 class="text-2xl font-bold">{{ dataState.isNew ? 'Create New Character' : 'Editing Character' }}</h1>

        <!-- Identity -->
        <Panel header="Identity">
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div class="flex flex-col gap-1">
                    <label for="characterName" class="text-sm font-medium">Character Name *</label>
                    <InputText id="characterName" v-model="form.characterName" fluid />
                </div>
                <div class="flex flex-col gap-1">
                    <label for="player" class="text-sm font-medium">Player *</label>
                    <InputText id="player" v-model="form.player" fluid />
                </div>
                <div class="flex flex-col gap-1">
                    <label for="ancestry" class="text-sm font-medium">Ancestry *</label>
                    <InputText id="ancestry" v-model="form.ancestry" fluid />
                </div>
                <div class="flex flex-col gap-1">
                    <label for="ancestrySpecies" class="text-sm font-medium">Ancestry Species *</label>
                    <InputText id="ancestrySpecies" v-model="form.ancestrySpecies" fluid />
                </div>
                <div class="flex flex-col gap-1">
                    <label for="path" class="text-sm font-medium">Core Path *</label>
                    <Select id="path" v-model="form.path" :options="paths" optionLabel="name" optionValue="name"
                        placeholder="Select a core path" fluid />
                </div>
                <div class="flex flex-col gap-1">
                    <label for="background" class="text-sm font-medium">Background</label>
                    <InputText id="background" v-model="form.background" fluid />
                </div>
                <div class="flex flex-col gap-1 sm:col-span-2">
                    <label for="imgUrl" class="text-sm font-medium">Portrait Image URL</label>
                    <InputText id="imgUrl" v-model="form.imgUrl" type="url" fluid />
                </div>
            </div>
        </Panel>

        <!-- Skills, Domains, Talents, Advances -->
        <Panel header="Skills &amp; Domains">
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div class="flex flex-col gap-1">
                    <label for="domains" class="text-sm font-medium">Domains</label>
                    <AutoComplete id="domains" v-model="form.domains" multiple :typeahead="false"
                        placeholder="Type and press Enter" fluid />
                </div>
                <div class="flex flex-col gap-1">
                    <label for="skills" class="text-sm font-medium">Skills</label>
                    <AutoComplete id="skills" v-model="form.skills" multiple :typeahead="false"
                        placeholder="Type and press Enter" fluid />
                </div>
                <div class="flex flex-col gap-1">
                    <label for="advances" class="text-sm font-medium">Advances</label>
                    <InputText id="advances" v-model="form.advances" fluid />
                </div>
            </div>
        </Panel>

        <!-- Talents (relational talent_instances) — only for existing characters -->
        <Panel v-if="!dataState.isNew" header="Talents">
            <LoadingState v-if="talentState.busy" />
            <div v-else class="flex flex-col gap-3">
                <div class="flex justify-end">
                    <Button type="button" label="Add Talents" icon="pi pi-plus"
                        @click="talentState.selectorVisible = true" />
                </div>
                <DataTable :value="talentState.instances" dataKey="id" paginator :rows="25">
                    <Column field="talents.name" header="Name" />
                    <Column field="talents.type" header="Type" />
                    <Column field="talents.description" header="Description" />
                    <Column header="" headerStyle="width: 7rem">
                        <template #body="{ data }">
                            <DangerButton type="button" label="Remove" @click="removeTalentInstance(data.id)" />
                        </template>
                    </Column>
                </DataTable>
            </div>

            <TalentSelector v-model:visible="talentState.selectorVisible" :character-id="route.params.id"
                :existing-talent-names="talentState.instances.map(t => t.talents?.name).filter(Boolean)"
                @saved="onTalentsSaved" />
        </Panel>

        <!-- Attributes -->
        <Panel header="Attributes">
            <div class="grid grid-cols-2 sm:grid-cols-3 gap-4">
                <div class="flex flex-col gap-1">
                    <label for="maxGuard" class="text-sm font-medium">Max Guard</label>
                    <InputNumber id="maxGuard" v-model="form.maxGuard" :min="0" fluid />
                </div>
                <div class="flex flex-col gap-1">
                    <label for="armor" class="text-sm font-medium">Armor</label>
                    <InputNumber id="armor" v-model="form.armor" :min="0" fluid />
                </div>
                <div class="flex flex-col gap-1">
                    <label for="maxBody" class="text-sm font-medium">Max Body</label>
                    <InputNumber id="maxBody" v-model="form.maxBody" :min="0" fluid />
                </div>
                <div class="flex flex-col gap-1">
                    <label for="maxSpeed" class="text-sm font-medium">Max Speed</label>
                    <InputNumber id="maxSpeed" v-model="form.maxSpeed" :min="0" fluid />
                </div>
                <div class="flex flex-col gap-1">
                    <label for="maxMind" class="text-sm font-medium">Max Mind</label>
                    <InputNumber id="maxMind" v-model="form.maxMind" :min="0" fluid />
                </div>
                <div class="flex flex-col gap-1">
                    <label for="maxSpirit" class="text-sm font-medium">Max Spirit</label>
                    <InputNumber id="maxSpirit" v-model="form.maxSpirit" :min="0" fluid />
                </div>
            </div>
        </Panel>

        <!-- Advancement counters -->
        <Panel header="Progression">
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div class="flex flex-col gap-1">
                    <label for="minorAdvances" class="text-sm font-medium">Minor Advances</label>
                    <InputNumber id="minorAdvances" v-model="form.minorAdvances" :min="0" fluid />
                </div>
                <div class="flex flex-col gap-1">
                    <label for="majorAdvances" class="text-sm font-medium">Major Advances</label>
                    <InputNumber id="majorAdvances" v-model="form.majorAdvances" :min="0" fluid />
                </div>
                <div class="flex flex-col gap-1">
                    <label for="pinnacleAdvances" class="text-sm font-medium">Pinnacle Advances</label>
                    <InputNumber id="pinnacleAdvances" v-model="form.pinnacleAdvances" :min="0" fluid />
                </div>
            </div>
        </Panel>

        <!-- Notes -->
        <Panel header="Notes">
            <Textarea v-model="form.notes" rows="5" fluid />
        </Panel>

        <!-- Actions -->
        <div class="flex flex-col gap-2">
            <small v-if="saveError" class="text-red-500">{{ saveError }}</small>
            <small v-else-if="!isFormValid" class="text-surface-500">
                Fill in all required fields (*) to save.
            </small>
            <div class="flex justify-end gap-2">
                <SecondaryButton type="button" label="Cancel" @click="cancel" />
                <Button type="submit" label="Save" :loading="saving" :disabled="!isFormValid || saving" />
            </div>
        </div>

    </form>
</template>
