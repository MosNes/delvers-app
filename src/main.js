import './assets/main.css'
import PrimeVue from 'primevue/config';

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

const app = createApp(App);

// tell Vue to use PrimeVue and enable unstyled mode to work with Volt and TailwindCSS
app.use(PrimeVue, {
    unstyled: true,
});

app.use(router)

app.mount('#app')
