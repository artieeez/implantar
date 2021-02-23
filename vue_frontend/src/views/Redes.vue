<template>
  <div>
    <NavBar></NavBar>
    <b-container class='baseOuterCon1'>
        <h1 class='text-primary'>Redes</h1>
        <b-container class='baseCon1'>
            <b-table
                head-variant='light'
                :busy="$store.getters.isLoading"
                striped
                small
                :borderless='false'
                :outlined='true'
                :items="items"
                :fields='fields'
            >
                <template #table-busy>
                    <div class="text-center text-primary my-2">
                    <b-spinner class="align-middle"></b-spinner>
                    <strong> Carregando...</strong>
                    </div>
                </template>
                <template #cell(index)="data">
                    <span :class='{
                        "font-italic": !data.item.is_active,
                        "text-muted": !data.item.is_active,
                        }'
                        class='ml-2'>{{ data.index + 1 }}</span>
                </template>

                <template #cell(nome)="data">
                    <span :class='{
                        "font-italic": !data.item.is_active,
                        "text-muted": !data.item.is_active,
                        }'>
                            <b-link :to="{ 
                                name: 'redes-details', 
                                params: { redeId: data.item.id }, 
                            }">
                                {{ data.value }}
                            </b-link>
                        </span>
                </template>
            </b-table>
            <b-row>
                <b-col sm='6' md='3' lg='3' class='mt-1'>
                    <b-form-checkbox
                        id="checkbox-1"
                        v-model="filter_options.is_active.in_use"
                        name="checkbox-1"
                        @change='fetchRedes()'
                        >
                        Esconder inativos
                    </b-form-checkbox>
                </b-col>
            </b-row>
        </b-container>
    </b-container>
  </div>
</template>

<script>
import NavBar from '../components/Navbar'
import { mapState } from 'vuex'
import * as helpers from '../helpers/index'

export default {
  name: "Redes",
  components: {NavBar},
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