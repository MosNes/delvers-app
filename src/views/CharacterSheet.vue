<script setup>
import Panel from '@/volt/Panel.vue';
</script>

<template>
  <!-- adjust padding on main -->
   <!-- flex flex-col creates vertical stack -->
  <main class="min-h-screen flex flex-col p-2">
    <!-- flex-1 creates a flex container that takes up the remaining space in the parent container -->
    <section class="flex flex-1 flex-col">
      <Panel>
        Character header, contains name, player, ancestry, destiny, path, background
      </Panel>
      <Panel>
        Contains Attribute Scores, Stress Tracks, and
      </Panel>
      <Panel>
        Contains Skills and Domains
      </Panel>
      <Panel>
        Contains Talents - use Volt Accordion component, use Multiple property and pass in value as array of dynamic
        Talent objects
      </Panel>
      <Panel>
        Contains Inventory
      </Panel>
    </section>
    <footer class="shrink-0 dark:text-surface-500">
      Contains nav buttons on mobile view. use Volt Drawer component for mobile view?
    </footer>
  </main>
</template>
