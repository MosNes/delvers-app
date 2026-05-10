<!-- the character sheet view displays all the information for a character, including their attributes, skills, talents, and inventory. -->
<script setup>
//import vue features
import { reactive } from 'vue';

//import components
import Panel from '@/volt/Panel.vue';
import Divider from '@/volt/Divider.vue';
import AttributeCard from '@/components/AttributeCard.vue';
import Button from '@/volt/Button.vue';
import SmallCard from '@/components/SmallCard.vue';

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
  destiny: "Destiny of the Frog",
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
      <Panel id="character-header-el">
        <!-- outer wrapper div flexbox for character header content -->
        <div class="flex flex-col gap-4 md:flex-row md:items-stretch">
          <!-- Portrait and name container: always at least ~50% -->
          <div id="character-name-and-portrait-el" class="flex w-full shrink-0 flex-row gap-4 md:w-1/2 md:max-w-none">
            <div
              class="max-w-[200px] max-h-[200px] min-w-[200px] rounded-2xl overflow-hidden border-2 border-[var(--p-accent-color)] shadow-[6px_6px_4px_rgba(0,0,0,0.35)]">
              <!--character portrait -->
              <img :src="charData.imgUrl" alt="Character Portrait" class="w-full h-full object-cover">
            </div>

            <!-- Contains character information -->
            <div class="min-w-0 flex-1">
              <div class="text-2xl font-bold">{{ charData.characterName }}</div>
              <div class="text-lg text-gray-400">{{ charData.player }}</div>

              <Divider />

              <div id="character-info-container-el" class="grid grid-cols-1 gap-2 lg:grid-cols-2">
                <div>
                  <div class="text-sm text-gray-400 font-display">Ancestry</div>
                  <div class="text-lg">{{ charData.ancestry }} {{ charData.ancestrySpecies }}</div>
                </div>

                <div>
                  <div class="text-sm text-gray-400 font-display">Destiny</div>
                  <div class="text-lg">{{ charData.destiny }}</div>
                </div>

                <div>
                  <div class="text-sm text-gray-400 font-display">Path</div>
                  <div class="text-lg">{{ charData.path }}</div>
                </div>

                <div>
                  <div class="text-sm text-gray-400 font-display">Background</div>
                  <div class="text-lg">{{ charData.background }}</div>
                </div>
              </div>


            </div>
          </div>


          <!-- action buttons for things like Rest, Advance, etc. -->
          <div id="action-buttons-el" class="flex w-full flex-col md:flex-1 md:min-h-0 lg:justify-end">
         
            <div class="flex flex-col gap-2 lg:flex-row lg:flex-wrap lg:justify-end">
              <Button icon="ra ra-meat" label="Snack" class="art-deco-frame font-display text-lg"/>
              <Button icon="ra ra-campfire" label="Rest" class="art-deco-frame font-display text-lg"/>
              <Button icon="ra ra-torch" label="Light" class="art-deco-frame font-display text-lg"/>
              <Button icon="ra ra-muscle-fat" label="Advancement" class="art-deco-frame font-display text-lg"/>
            </div>
          </div>

        </div>



      </Panel>
      <Divider />
      <Panel id="attribute-scores-el">
        <!-- Contains Attribute Scores, Stress Tracks, and Blessings/Curses counters -->
        <!-- atribute cards for body, speed, mind, and spirit -->
        <div class="flex flex-row flex-wrap items-stretch justify-center gap-4">
          <!-- guard tracker and armor -->
           <div class="flex flex-col gap-4 self-stretch min-h-0">
            <SmallCard title="Guard" :value="charData.currentGuard" :maxValue="charData.maxGuard" :hasMaxValue="true"
            class="min-h-0 flex-1" />
            <SmallCard title="Armor" :value="charData.armor" 
            class="min-h-0 flex-1"/>
           </div>
          
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
      <Panel id="skills-and-domains-el">
        Contains Skills and Domains
      </Panel>
      <Divider />
      <Panel id="talents-el">
        Contains Talents - use Volt Accordion component, use Multiple property and pass in value as array of dynamic
        Talent objects
      </Panel>
      <Panel id="inventory-el">
        Contains Inventory
      </Panel>
    </section>
    <footer class="shrink-0 dark:text-surface-500" id="footer-el">
      Contains nav buttons on mobile view. use Volt Drawer component for mobile view?
    </footer>
  </main>
</template>
