<template>
    <div class="p-6 flex flex-col gap-8 max-w-6xl mx-auto">

        <!-- Characters -->
        <Panel header="Characters">
            <div v-if="charactersLoading" class="text-surface-500 text-sm">Loading characters…</div>
            <div v-else-if="charactersError" class="text-red-500 text-sm">{{ charactersError }}</div>
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
                </Card>
            </div>
        </Panel>

        <!-- Campaigns -->
        <Panel header="Campaigns">
            <div v-if="campaignsLoading" class="text-surface-500 text-sm">Loading campaigns…</div>
            <div v-else-if="campaignsError" class="text-red-500 text-sm">{{ campaignsError }}</div>
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
import { ref, onMounted } from 'vue'
import Panel from '@/volt/Panel.vue'
import Card from '@/volt/Card.vue'
import { supabase } from '@/lib/supabaseClient'
import { useAuth } from '@/composables/useAuth'

const { user } = useAuth()

const characters = ref([])
const charactersLoading = ref(true)
const charactersError = ref('')

const campaigns = ref([])
const campaignsLoading = ref(true)
const campaignsError = ref('')

onMounted(async () => {
    const userId = user.value?.id
    if (!userId) return

    await Promise.all([fetchCharacters(userId), fetchCampaigns(userId)])
})

async function fetchCharacters(userId) {
    const { data, error } = await supabase
        .from('characters')
        .select('id, characterName, ancestrySpecies, path, imgUrl')
        .eq('owner', userId)

    charactersLoading.value = false
    if (error) { charactersError.value = error.message; return }
    characters.value = data
}

async function fetchCampaigns(userId) {
    // Step 1: find campaign IDs the user participates in via their characters.
    const { data: charRows, error: charErr } = await supabase
        .from('characters')
        .select('campaign')
        .eq('owner', userId)
        .not('campaign', 'is', null)

    if (charErr) {
        campaignsLoading.value = false
        campaignsError.value = charErr.message
        return
    }

    const memberIds = [...new Set(charRows.map(r => r.campaign))]

    // Step 2: fetch campaigns owned by the user, plus any they participate in.
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
    campaignsLoading.value = false
    if (error) { campaignsError.value = error.message; return }
    campaigns.value = data
}
</script>
