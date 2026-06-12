<template>
    <div class="min-h-screen flex flex-col items-center justify-center gap-6">
        <h1 class="text-4xl font-bold text-center">Welcome to the Delvers App</h1>
        <p class="text-lg text-surface-500 text-center">This app is under construction</p>
        <div class="flex gap-4">
            <Button as="router-link" to="/signup" label="Sign Up" class="art-deco-frame font-display text-lg" />
            <Button as="router-link" to="/login" label="Log In" class="art-deco-frame font-display text-lg" />
        </div>
    </div>
</template>

<script setup>
import Button from '@/volt/Button.vue';
</script>
