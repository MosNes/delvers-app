<!-- the character sheet view displays all the information for a character, including their attributes, skills, talents, and inventory. -->
<script setup>
//import vue features
import { reactive, ref, watch, onMounted, onUnmounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';

//import supabase client
import { supabase } from '@/lib/supabaseClient';

//import components
import LoadingState from '@/components/LoadingState.vue';
import Panel from '@/volt/Panel.vue';
import Divider from '@/volt/Divider.vue';
import AttributeCard from '@/components/AttributeCard.vue';
import Button from '@/volt/Button.vue';
import SmallCard from '@/components/SmallCard.vue';
import SkillCard from '@/components/SkillCard.vue';
import Accordion from '@/volt/Accordion.vue';
import AccordionPanel from '@/volt/AccordionPanel.vue';
import AccordionHeader from '@/volt/AccordionHeader.vue';
import AccordionContent from '@/volt/AccordionContent.vue';
import DangerButton from '@/volt/DangerButton.vue';
import InventorySelector from '@/components/InventorySelector.vue';
import SavingState from '@/components/SavingState.vue';
import Textarea from '@/volt/Textarea.vue';

//test character data
const charData = reactive({
  owner: "00000000-0000-0000-0000-000000000001",
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
  skills: ["Frogmannerisms", "Sleight of Frog", "Frogjitsu", "Antidisestablishmentarianism"],
  talents: ["Favored Weapon"],
  advances: [],
  inventory: [],
  minorAdvances: 0,
  majorAdvances: 0,
  pinnacleAdvances: 0,
  maxGuard: 4,
  currentGuard: 0,
  armor: 0,
  maxBody: 10,
  currentBody: 4,
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

const dataState = reactive({ isLoaded: false, isError: false });

// talent instances for this character (single reactive state object)
const talentState = reactive({ instances: [] });

// inventory instances for this character (single reactive state object)
const invState = reactive({ instances: [], busy: false, selectorVisible: false });

// autosave state (single reactive state object) + popover ref + debounce timer
const saveState = reactive({ isError: false, errorMessage: '' });
const savingState = ref(null);
let saveTimer = null;

// route gives us access to the :id param (the character's uuid in supabase)
const route = useRoute();
const router = useRouter();

// debounced autosave: 5s after the last change to charData, persist the row.
// Set up once after the initial load so populating charData doesn't trigger a save.
function autosave() {
    watch(charData, () => {
        if (saveTimer) clearTimeout(saveTimer);
        saveTimer = setTimeout(performSave, 5000);
    }, { deep: true });
}

async function performSave() {
    saveState.isError = false;
    saveState.errorMessage = '';
    savingState.value?.show();

    // destiny and inventory are not columns on the characters table — exclude them
    const { destiny, inventory, ...payload } = charData;
    const { error } = await supabase
        .from('characters')
        .update(payload)
        .eq('id', route.params.id);

    if (error) {
        // keep the popover open showing the error; the next change reschedules a save
        saveState.isError = true;
        saveState.errorMessage = error.message;
    } else {
        savingState.value?.hide();
    }
}

onUnmounted(() => {
    if (saveTimer) clearTimeout(saveTimer);
});

// route to the edit character view for this character
function editCharacter() {
    router.push({ name: 'edit-character', params: { id: route.params.id } });
}

async function fetchInventoryInstances() {
    const { data, error } = await supabase
        .from('inventory_instances')
        .select('id, itemType, baseItem, displayName, isEquipped, stackValue')
        .eq('character_id', route.params.id);

    if (error) throw error;
    invState.instances = data;
}

async function removeInventoryInstance(id) {
    invState.busy = true;
    try {
        const { error } = await supabase.from('inventory_instances').delete().eq('id', id);
        if (error) throw error;
        await fetchInventoryInstances();
    } catch (err) {
        console.error('Failed to remove inventory item:', err);
    } finally {
        invState.busy = false;
    }
}

async function onInventorySaved() {
    invState.selectorVisible = false;
    invState.busy = true;
    try {
        await fetchInventoryInstances();
    } catch (err) {
        console.error('Failed to refresh inventory:', err);
    } finally {
        invState.busy = false;
    }
}

onMounted(async () => {
    try {
        // fetch the character row (.single() errors if 0 or >1 rows match) and
        // its talent instances in parallel.
        const [charResult, talentsResult] = await Promise.all([
            supabase.from('characters').select('*').eq('id', route.params.id).single(),
            supabase
                .from('talent_instances')
                .select('id, talent_name, value')
                .eq('character_id', route.params.id),
            fetchInventoryInstances(),
        ]);

        if (charResult.error) throw charResult.error;
        if (talentsResult.error) throw talentsResult.error;

        const data = charResult.data;
        talentState.instances = talentsResult.data;

        // populate charData from the returned row. Each property below
        // references a column on the characters table.
        charData.owner = data.owner;
        charData.campaign = data.campaign;
        charData.imgUrl = data.imgUrl;
        charData.characterName = data.characterName;
        charData.player = data.player;
        charData.ancestry = data.ancestry;
        charData.ancestrySpecies = data.ancestrySpecies;
        charData.path = data.path;
        charData.background = data.background;
        charData.domains = data.domains;
        charData.skills = data.skills;
        charData.talents = data.talents;
        charData.advances = data.advances;
        charData.minorAdvances = data.minorAdvances;
        charData.majorAdvances = data.majorAdvances;
        charData.pinnacleAdvances = data.pinnacleAdvances;
        charData.maxGuard = data.maxGuard;
        charData.currentGuard = data.currentGuard;
        charData.armor = data.armor;
        charData.maxBody = data.maxBody;
        charData.currentBody = data.currentBody;
        charData.maxSpeed = data.maxSpeed;
        charData.currentSpeed = data.currentSpeed;
        charData.maxMind = data.maxMind;
        charData.currentMind = data.currentMind;
        charData.maxSpirit = data.maxSpirit;
        charData.currentSpirit = data.currentSpirit;
        charData.blessings = data.blessings;
        charData.curses = data.curses;
        charData.doom = data.doom;
        charData.bodyStress = data.bodyStress;
        charData.speedStress = data.speedStress;
        charData.mindStress = data.mindStress;
        charData.spiritStress = data.spiritStress;
        charData.notes = data.notes;

        dataState.isLoaded = true;

        // start watching for changes now that charData is fully populated
        autosave();
    } catch (err) {
        console.error('Failed to load character:', err);
        dataState.isError = true;
        dataState.isLoaded = true;
    }
});
</script>

<template>
  <LoadingState v-if="!dataState.isLoaded" :is-error="dataState.isError" class="min-h-screen" />
  <!-- flex flex-col creates vertical stack -->
  <main v-else class="min-h-screen flex flex-col p-2">
    <SavingState ref="savingState" :is-error="saveState.isError" :error-message="saveState.errorMessage" />
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
              <Button icon="ra ra-meat" label="Snack" class="art-deco-frame font-display text-lg" />
              <Button icon="ra ra-campfire" label="Rest" class="art-deco-frame font-display text-lg" />
              <Button icon="ra ra-torch" label="Light" class="art-deco-frame font-display text-lg" />
              <Button icon="ra ra-muscle-fat" label="Advancement" class="art-deco-frame font-display text-lg" />
              <Button icon="ra ra-quill-ink" label="Edit" class="art-deco-frame font-display text-lg" @click="editCharacter" />
            </div>
          </div>

        </div>



      </Panel>
      <Divider />
      <Panel id="attribute-scores-el">
        <!-- Contains Attribute Scores, Stress Tracks, and Blessings/Curses counters -->
        <div class="flex flex-row flex-wrap items-stretch justify-center gap-4">

          <!-- guard tracker and armor -->
          <div class="flex flex-col gap-4 self-stretch min-h-0">
            <SmallCard title="Guard" v-model:value="charData.currentGuard" :maxValue="charData.maxGuard" :hasMaxValue="true"
              class="min-h-0 flex-1" />
            <SmallCard title="Armor" v-model:value="charData.armor" class="min-h-0 flex-1" />
          </div>

          <!-- body attribute card -->
          <AttributeCard attributeTitle="Body" :maxValue="charData.maxBody" v-model:currentValue="charData.currentBody"
            v-model:stressMarked="charData.bodyStress" />
          <!-- speed attribute card -->
          <AttributeCard attributeTitle="Speed" :maxValue="charData.maxSpeed" v-model:currentValue="charData.currentSpeed"
            v-model:stressMarked="charData.speedStress" />
          <!-- mind attribute card -->
          <AttributeCard attributeTitle="Mind" :maxValue="charData.maxMind" v-model:currentValue="charData.currentMind"
            v-model:stressMarked="charData.mindStress" />
          <!-- spirit attribute card -->
          <AttributeCard attributeTitle="Spirit" :maxValue="charData.maxSpirit" v-model:currentValue="charData.currentSpirit"
            v-model:stressMarked="charData.spiritStress" />

          <!-- blessings and curses counters -->
          <div class="flex flex-col gap-4 self-stretch min-h-0">
            <SmallCard title="Blessings" v-model:value="charData.blessings"
              class="min-h-0 flex-1" />
            <SmallCard title="Curses" v-model:value="charData.curses" class="min-h-0 flex-1" />
          </div>

        </div>
      </Panel>
      <Divider />
      <Panel id="skills-and-domains-el">
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <SkillCard title="Skills" :contentArray="charData.skills" />
          <SkillCard title="Domains" :contentArray="charData.domains" />
        </div>
      </Panel>
      <Divider />
      <Panel id="talents-el" header="Talents">
        <Accordion>
          <AccordionPanel v-for="talent in talentState.instances" :key="talent.id" :value="talent.id">
            <AccordionHeader class="font-display text-2xl">{{ talent.talent_name }}</AccordionHeader>
            <AccordionContent class="p-3 text-lg art-deco-frame">
              <div class="text-md text-gray-400 font-display">Path</div>
              <div class="mb-2">{{ talent.value?.path_name }}</div>
              <div class="text-md text-gray-400 font-display">Type</div>
              <div class="mb-2">{{ talent.value?.type }}</div>
              <div class="text-md text-gray-400 font-display">Description</div>
              <div class="mb-2">{{ talent.value?.description }}</div>
              <div v-if="talent.value?.flavorText" class="mb-2 italic text-gray-400">{{ talent.value.flavorText }}</div>
              <div v-if="talent.value?.selectedValue !== null && talent.value?.selectedValue !== undefined">
                <div class="text-md text-gray-400 font-display">Selection</div>
                <div>{{ talent.value.selectedValue }}</div>
              </div>
            </AccordionContent>
          </AccordionPanel>
        </Accordion>
      </Panel>
      <Divider />
      <Panel id="inventory-el" header="Inventory">
        <LoadingState v-if="invState.busy" />
        <div v-else class="flex flex-col gap-3">
          <div class="flex justify-end">
            <Button type="button" label="Add Items" icon="pi pi-plus"
              @click="invState.selectorVisible = true" />
          </div>
          <Accordion>
            <AccordionPanel v-for="item in invState.instances" :key="item.id" :value="item.id">
              <AccordionHeader class="font-display text-2xl">{{ item.displayName }}</AccordionHeader>
              <AccordionContent class="p-3 text-lg art-deco-frame">
                <div class="text-md text-gray-400 font-display">Type</div>
                <div class="mb-2">{{ item.itemType }}</div>
                <div class="text-md text-gray-400 font-display">Equipped</div>
                <div class="mb-2">{{ item.isEquipped ? 'Yes' : 'No' }}</div>
                <div class="flex justify-end">
                  <DangerButton type="button" label="Remove" @click="removeInventoryInstance(item.id)" />
                </div>
              </AccordionContent>
            </AccordionPanel>
          </Accordion>
        </div>

        <InventorySelector v-model:visible="invState.selectorVisible" :character-id="route.params.id"
          @saved="onInventorySaved" />
      </Panel>
    </section>
    <Divider />
    <section>
      <Panel id="notes-el">
        <div class="text-2xl font-bold font-display mb-2">Notes</div>
        <Textarea v-model="charData.notes" fluid />
      </Panel>
    </section>
    <Divider />
    <footer class="shrink-0 dark:text-surface-500" id="footer-el">
      <Panel id="gambits-el">
        <div class="text-2xl font-bold font-display">Gambits</div>
        <div class="italic text-gray-400 text-lg">4+ or higher on damage roll</div>
        <Divider />
        <div class="text-xl">
          <ul>
            <li class="p-1"><i class="ra ra-sword"></i> Press the attack for +1 total damage</li>
            <li class="p-1"><i class="ra ra-feather-wing"></i> Move after the Attack, even if you already moved or are unable to move</li>
            <li class="p-1"><i class="ra ra-shield"></i> Repel an enemy away from you</li>
            <li class="p-1"><i class="ra ra-nails"></i> Pin an opponent down, preventing them from moving next turn</li>
            <li class="p-1"><i class="ra ra-broken-bone"></i> Impair an opponent's next attack</li>
            <li class="p-1"><i class="ra ra-cracked-shield"></i> Expose a weak point, so all attacks ignore 1 point of Armor until your next turn</li>
            <li class="p-1"><i class="ra ra-flame-symbol"></i> Other effects of similar impact</li>
          </ul>
        </div>
      </Panel>
      <Divider />
      <Panel id="curses-el">
        <div class="text-2xl font-bold font-display">Curses</div>
        <div class="italic text-gray-400 text-lg">Spend 1 Curse to activate</div>
        <Divider />
        <div class="text-xl">
          <ul>
            <li class="p-1"><i class="ra ra-doubled"></i> Reroll a single die of an Action Roll, Save, or Attack Pool</li>
            <li class="p-1"><i class="ra ra-doubled"></i> Gain +3 Boons to an Action Roll or Save, after the dice are rolled but before the outcome is resolved</li>
          </ul>
        </div>
      </Panel>
      <Divider />
      <Panel id="blessings-el">
        <div class="text-2xl font-bold font-display">Blessings</div>
        <div class="italic text-gray-400 text-lg">Spend 1 Blessing to activate</div>
        <Divider />
        <div class="text-xl">
          <ul>
            <li class="p-1"><i class="ra ra-sun"></i> Ask the GM a specific question about a situation and receive a truthful answer</li>
            <li class="p-1"><i class="ra ra-sun"></i> Spend Blessings in place of Stress to activate a Talent</li>
          </ul>
        </div>
      </Panel>
    </footer>
  </main>
</template>
