<template>
    <LoadingState v-if="!dataState.isLoaded" :is-error="dataState.isError" />
    <div v-else class="p-6 flex flex-col gap-8 max-w-6xl mx-auto">

        <!-- Characters -->
        <Panel header="Characters">
            <div class="flex justify-end mb-4">
                <Button v-if="characters.length < 5" label="New Character" icon="pi pi-plus"
                    @click="newCharacter" />
            </div>
            <div v-if="charactersError" class="text-red-500 text-sm">{{ charactersError }}</div>
            <div v-else-if="characters.length === 0" class="text-surface-500 text-sm">No characters yet.</div>
            <div v-else class="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
                <Card v-for="char in characters" :key="char.id">
                    <template #header>
                        <div class="w-full aspect-square overflow-hidden rounded-t-xl bg-surface-100 dark:bg-surface-700 flex items-center justify-center">
                            <img
                                v-if="char.imgUrl"
                                :src="char.imgUrl"
                                :alt="char.characterName"
                                class="w-full h-full object-cover"
                            />
                            <span v-else class="text-4xl text-surface-400 select-none">?</span>
                        </div>
                    </template>
                    <template #title>{{ char.characterName }}</template>
                    <template #subtitle>{{ char.ancestrySpecies }}</template>
                    <template #content>
                        <span class="text-sm text-surface-500">{{ char.path }}</span>
                    </template>
                    <template #footer>
                        <div class="flex gap-2">
                            <Button label="View" icon="pi pi-eye" class="flex-1"
                                @click="viewCharacter(char.id)" />
                            <SecondaryButton label="Edit" icon="pi pi-pencil" outlined
                                class="flex-1" @click="editCharacter(char.id)" />
                        </div>
                    </template>
                </Card>
            </div>
        </Panel>

        <!-- Campaigns -->
        <Panel header="Campaigns">
            <div v-if="campaignsError" class="text-red-500 text-sm">{{ campaignsError }}</div>
            <div v-else-if="campaigns.length === 0" class="text-surface-500">No Campaigns</div>
            <ul v-else class="flex flex-col gap-2">
                <li
                    v-for="campaign in campaigns"
                    :key="campaign.id"
                    class="flex flex-col rounded-md border border-surface-200 dark:border-surface-700 px-4 py-3"
                >
                    <span class="font-medium">{{ campaign.name }}</span>
                    <span v-if="campaign.description" class="text-sm text-surface-500">{{ campaign.description }}</span>
                </li>
            </ul>
        </Panel>

    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Panel from '@/volt/Panel.vue'
import Card from '@/volt/Card.vue'
import Button from '@/volt/Button.vue'
import SecondaryButton from '@/volt/SecondaryButton.vue'
import LoadingState from '@/components/LoadingState.vue'
import { supabase } from '@/lib/supabaseClient'
import { useAuth } from '@/composables/useAuth'

const { user } = useAuth()
const router = useRouter()

// route to a blank EditCharacter view for creating a new character
function newCharacter() {
    router.push({ name: 'new-character' })
}

// open the read-only character sheet for the given character uuid
function viewCharacter(id) {
    router.push({ name: 'character', params: { id } })
}

// open the edit character view for the given character uuid
function editCharacter(id) {
    router.push({ name: 'edit-character', params: { id } })
}

const dataState = reactive({ isLoaded: false, isError: false })

const characters = ref([])
const charactersError = ref('')

const campaigns = ref([])
const campaignsError = ref('')

onMounted(async () => {
    const userId = user.value?.id
    if (!userId) {
        dataState.isLoaded = true
        return
    }

    await Promise.all([fetchCharacters(userId), fetchCampaigns(userId)])
    dataState.isLoaded = true
})

async function fetchCharacters(userId) {
    const { data, error } = await supabase
        .from('characters')
        .select('id, characterName, ancestrySpecies, path, imgUrl')
        .eq('owner', userId)

    if (error) { charactersError.value = error.message; return }
    characters.value = data
}

async function fetchCampaigns(userId) {
    const { data: charRows, error: charErr } = await supabase
        .from('characters')
        .select('campaign')
        .eq('owner', userId)
        .not('campaign', 'is', null)

    if (charErr) {
        campaignsError.value = charErr.message
        return
    }

    const memberIds = [...new Set(charRows.map(r => r.campaign))]

    const query = memberIds.length > 0
        ? supabase
            .from('campaigns')
            .select('id, name, description')
            .or(`campaign_owner.eq.${userId},id.in.(${memberIds.join(',')})`)
        : supabase
            .from('campaigns')
            .select('id, name, description')
            .eq('campaign_owner', userId)

    const { data, error } = await query
    if (error) { campaignsError.value = error.message; return }
    campaigns.value = data
}
</script>
