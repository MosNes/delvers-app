<script setup>
import Card from '@/volt/Card.vue';

const props = defineProps({
    title: {
        type: String,
        required: true
    },
    contentArray: {
        type: Array,
        required: true
    }
});


</script>

<style scoped>
.attribute-card-border :deep(.rounded-xl) {
    border-radius: 0;
}
</style>

<template>
    <div class="attribute-card-border">
        <Card class="h-full">
            <template #header>
                <div class="text-center text-2xl font-display translate-y-4">
                    {{ title }}
                </div>
            </template>
            <template #content>
                <div class="p-2">
                    <ul v-for="item in contentArray" :key="item">
                    <li class="text-lg">
                        {{ item }}
                    </li>
                </ul>
                </div>
                
            </template>
        </Card>
    </div>

</template>
