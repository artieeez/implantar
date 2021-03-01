<template>
<div>
<b-container class='baseOuterCon1'>
    <h3 class='text-primary'>Categorias</h3>
    <b-table
        head-variant='light'
        :busy="$store.getters.isLoading"
        fixed
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
                }'>{{ data.value }}</span>
        </template>

        <template #cell(show_details)="row">
            <div class='actionCell'>
                <b-button size="sm" @click="row.toggleDetails" class="mr-2">
                    <b-icon-info-circle v-show='!row.detailsShowing'/>
                    <b-icon-x-circle-fill v-show='row.detailsShowing'/>
                </b-button>
            </div>
        </template>
        <template #row-details="row">
            <b-card>
                <b-row class="mb-2">
                    <b-col sm="2" class="text-sm-right"><b>Ativo:</b></b-col>
                    <b-col>{{ row.item.is_active ? 'Ativo' : 'Inativo' }}</b-col>
                </b-row>
                <b-row>
                    <b-button
                        variant="warning"
                        class='ml-2'
                        size='sm'
                        @click="categoria_active_change(row.item.id, !row.item.is_active)"
                        >
                        <span v-if='row.item.is_active'><b-icon-lock-fill/> Desativar categoria</span>
                        <span v-if='!row.item.is_active'><b-icon-unlock-fill/> Ativar categoria</span>
                        </b-button>
                    <DeleteButton
                        :id='row.item.id'
                        model='categoria'
                        :item='row.item'/>
                </b-row>
            </b-card>
        </template>
    </b-table>
    <b-row>
        <b-col sm='6' md='3' lg='3' class='mt-1'>
            <NovaCategoria/>
        </b-col>
        <b-col sm='6' md='3' lg='3' class='mt-1'>
            <b-form-checkbox
                id="checkbox-1"
                v-model="filter_options.is_active.in_use"
                name="checkbox-1"
                @change='fetchCategorias()'
                >
                Esconder inativos
            </b-form-checkbox>
        </b-col>
    </b-row>
</b-container>
</div>
</template>

<script>
import { mapState } from 'vuex'
import * as helpers from '../../helpers/index'
import NovaCategoria from './NovaCategoria'
import DeleteButton from './DeleteButton'

export default {
  name: "Categoria",
  components: {NovaCategoria, DeleteButton},
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
            {
                key: 'show_details',
                label: ''
            },
        ],
        selected: [],
    };
  },
  computed: {
      ...mapState(['categorias']),
      items() {
          let items = [];
          for (let i = 0; i < this.categorias.length; i++) {
              let row = this.categorias[i]
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
    this.fetchCategorias();
  },
  methods: {
    onRowSelected(items) {
        this.selected = items
    },
    async categoria_active_change(id, boolean) {
        this.$store.commit('setLoading', true);
        let success = false;
        let store = this.$store;
        let count = 1;
        let categoria = {
            id: id,
            data: {
                is_active: boolean
            }
        }
        do {
            await store.dispatch('categoria_partial_update', categoria)
                .then(() => {
                    success = true; // Breaks do while
                    this.fetchCategorias();
                })
                .catch(async err => { // 1* Função anônima async
                    if (err.config && err.response && err.response.status === 401) { 
                        await store.dispatch('refreshToken') // attempt to obtain new access token by running 'refreshToken' action
                    }
                })
            await helpers.sleep(500);
            count++;
        } while (!success && count < 10);
    },
    async fetchCategorias() {
        this.$store.commit('setLoading', true);
        let success = false;
        let store = this.$store;
        let count = 1;
        do {
            await store.dispatch('fetchCategorias', this.filter_options)
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
.actionCell {
    display: flex;
    flex-direction: row-reverse;
}
</style>