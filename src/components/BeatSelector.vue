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
    destinyId: { type: String, default: null }, // destiny_tracker.destiny_id
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
        // #region agent log
        fetch('http://127.0.0.1:7404/ingest/2d4e9d71-11c8-44e4-9942-b525874d6801',{method:'POST',headers:{'Content-Type':'application/json','X-Debug-Session-Id':'479103'},body:JSON.stringify({sessionId:'479103',runId:'run1',hypothesisId:'A',location:'BeatSelector.vue:fetchBeats-entry',message:'fetchBeats called',data:{destinyId:props.destinyId,destinyIdType:typeof props.destinyId},timestamp:Date.now()})}).catch(()=>{});
        // #endregion
        // beats.destiny_id → destinies(id); filter directly by the character's destiny_id.
        const { data, error } = await supabase
            .from('beats')
            .select('id, type, description')
            .eq('destiny_id', props.destinyId)
            .order('type')

        // #region agent log
        fetch('http://127.0.0.1:7404/ingest/2d4e9d71-11c8-44e4-9942-b525874d6801',{method:'POST',headers:{'Content-Type':'application/json','X-Debug-Session-Id':'479103'},body:JSON.stringify({sessionId:'479103',runId:'run1',hypothesisId:'B,C',location:'BeatSelector.vue:fetchBeats-query',message:'beats query result',data:{rowCount:Array.isArray(data)?data.length:null,error:error?{message:error.message,code:error.code,details:error.details}:null,queriedDestinyId:props.destinyId},timestamp:Date.now()})}).catch(()=>{});
        // #endregion

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
