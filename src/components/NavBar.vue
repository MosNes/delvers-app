<template>
    <Drawer v-model:visible="drawerVisible" position="left">
        <template #header>Menu</template>
        <nav class="flex flex-col gap-1 pt-2">
            <RouterLink
                to="/dashboard"
                class="flex items-center gap-3 px-3 py-2 rounded-md text-surface-700 dark:text-surface-200 hover:bg-surface-100 dark:hover:bg-surface-700 transition-colors duration-200"
                @click="drawerVisible = false"
            >
                <i class="pi pi-home" />
                Dashboard
            </RouterLink>
        </nav>
    </Drawer>

    <div class="sticky top-0 z-50">
        <Toolbar>
            <template #start>
                <SecondaryButton icon="pi pi-bars" variant="text" rounded @click="drawerVisible = true" />
                <span class="font-display text-xl pl-2">Delvers</span>
            </template>
            <template #end>
                <SecondaryButton icon="pi pi-sign-out" variant="text" rounded @click="handleLogout" />
            </template>
        </Toolbar>
    </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import Toolbar from '@/volt/Toolbar.vue'
import Drawer from '@/volt/Drawer.vue'
import SecondaryButton from '@/volt/SecondaryButton.vue'
import { supabase } from '@/lib/supabaseClient'

const router = useRouter()
const drawerVisible = ref(false)

async function handleLogout() {
    await supabase.auth.signOut()
    router.replace('/')
}
</script>
