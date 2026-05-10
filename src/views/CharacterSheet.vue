<!-- the character sheet view displays all the information for a character, including their attributes, skills, talents, and inventory. -->
<script setup>
//import vue features
import { reactive } from 'vue';

//import components
import Panel from '@/volt/Panel.vue';
import Divider from '@/volt/Divider.vue';
import AttributeCard from '@/components/AttributeCard.vue';

//test character data
// actual character data will be imported from pinia store
const charData = reactive({
  owner: "test@test.com",
  campaign: 1,
  imgUrl: "https://cdn.pixabay.com/photo/2024/04/21/09/20/ai-generated-8710168_640.jpg",
  characterName: "Jimothy P Frogman",
  player: "Test Player",
  ancestry: "Xolotl",
  ancestrySpecies: "Green Tree Frog",
  destiny: 1,
  path: "Path of the Warrior",
  background: "Test Background",
  domains: ["Froggery", "Mannerisms"],
  skills: ["Frogmannerisms"],
  talents: ["Favored Weapon"],
  advances: [],
  minorAdvances: 0,
  majorAdvances: 0,
  pinnacleAdvances: 0,
  maxGuard: 4,
  currentGuard: 4,
  armor: 0,
  maxBody: 10,
  currentBody: 10,
  maxSpeed: 11,
  currentSpeed: 11,
  maxMind: 8,
  currentMind: 8,
  maxSpirit: 13,
  currentSpirit: 13,
  blessings: 0,
  curses: 0,
  doom: 0,
  bodyStress: false,
  speedStress: false,
  mindStress: false,
  spiritStress: false,
  notes: "JIMMY FROGMAN IS A FROGMAN"
});

// sheet view state data
const viewData = reactive({
});

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
        <div class="flex flex-row flex-wrap items-stretch justify-center gap-4">
          <!-- body attribute card -->
          <AttributeCard attributeTitle="Body" :maxValue="charData.maxBody" :currentValue="charData.currentBody"
            :stressMarked="charData.bodyStress" />
          <!-- speed attribute card -->
          <AttributeCard attributeTitle="Speed" :maxValue="charData.maxSpeed" :currentValue="charData.currentSpeed"
            :stressMarked="charData.speedStress" />
          <!-- mind attribute card -->
          <AttributeCard attributeTitle="Mind" :maxValue="charData.maxMind" :currentValue="charData.currentMind"
            :stressMarked="charData.mindStress" />
          <!-- spirit attribute card -->
          <AttributeCard attributeTitle="Spirit" :maxValue="charData.maxSpirit" :currentValue="charData.currentSpirit"
            :stressMarked="charData.spiritStress" />
            
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
