<template>
  <div>
    <NavBar></NavBar>
    <b-container class='baseOuterCon1'>
        <h1 class='text-primary'>Checklists</h1>
        <b-container class='baseCon1'>
            <Categoria/>
        </b-container>
    </b-container>
  </div>
</template>

<script>
import NavBar from '../components/Navbar'
import { mapState } from 'vuex'
import * as helpers from '../helpers/index'
import Categoria from '../components/checklists/Categoria'


export default {
  name: "Checklists",
  components: {NavBar, Categoria},
  data() {
    return {
        filter_options: {
            is_active: {
                in_use: true,
                value: true,
            }
        },
        fields: [
            {
                key: 'index',
                label: '',
            },
            {
                key: 'nome',
                label: 'Nome',
                sortable: true,
            },
        ],
        selected: [],
    };
  },
  computed: {
      ...mapState(['redes']),
      items() {
          let items = [];
          for (let i = 0; i < this.redes.length; i++) {
              let row = this.redes[i]
              row.show_details = false;
              items.push(row);
          }
          return items;
      },
  },
  async beforeCreate() {
      this.$store.commit('setLoading', true);
  },
  async created() {
    // Observar as DUAS declarações async em 'created()' e na função anônima,
    // de forma que se evite um stack overflow.
    this.fetchRedes();
  },
  methods: {
    async fetchRedes() {
        this.$store.commit('setLoading', true);
        let success = false;
        let store = this.$store;
        let count = 1;
        do {
            await store.dispatch('fetchRedes', this.filter_options)
                .then(() => {
                    success = true; // Breaks do while
                    this.$store.commit('setLoading', false);
                })
                .catch(async err => { // 1* Função anônima async
                    if (err.config && err.response && err.response.status === 401) { 
                        await store.dispatch('refreshToken') // attempt to obtain new access token by running 'refreshToken' action
                    }
                })
            await helpers.sleep(500);
            count++;
        } while (!success && count < 10);
    }
  },
};
</script>

<style scoped>
@media (min-width: 768px) {
}
@media (min-width: 992px) {
}
@media (min-width: 1200px) {
}
</style>