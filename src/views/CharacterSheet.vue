<script setup>
import Panel from '@/volt/Panel.vue';
import Divider from '@/volt/Divider.vue';
import AttributeCard from '@/components/AttributeCard.vue';
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
      <Divider />
      <Panel>
        <!-- Contains Attribute Scores, Stress Tracks, and Blessings/Curses counters -->
        <!-- atribute cards for body, speed, mind, and spirit -->
        <div class="flex flex-row flex-wrap items-stretch justify-center gap-2">
          <AttributeCard attributeTitle="Body" maxValue="10" currentValue="5" stressMarked="true" />
          <AttributeCard attributeTitle="Speed" maxValue="10" currentValue="5" stressMarked="true" />
          <AttributeCard attributeTitle="Mind" maxValue="10" currentValue="5" stressMarked="true" />
          <AttributeCard attributeTitle="Spirit" maxValue="10" currentValue="5" stressMarked="true" />
        </div>
      </Panel>
      <Divider />
      <Panel>
        Contains Skills and Domains
      </Panel>
      <Divider />
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
