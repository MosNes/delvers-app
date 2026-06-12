<script setup>
import { RouterView } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import NavBar from '@/components/NavBar.vue'

const { user } = useAuth()
</script>

<template>
  <NavBar v-if="user" />
  <RouterView />
</template>