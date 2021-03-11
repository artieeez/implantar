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
        <template #cell(id_arb)="data">
            <div :class='{
                "font-italic": !data.item.is_active,
                "text-muted": !data.item.is_active,
                }'
                class='ml-2 mt-1'
            >
                <Ordem
                    :id='data.item.id'
                    :index='data.value'
                    model='categoria'
                    :length='items.length'
                    />
            </div>
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
import Ordem from './Ordem'
import NovaCategoria from './NovaCategoria'
import DeleteButton from './DeleteButton'

export default {
  name: "Categoria",
  components: {Ordem, NovaCategoria, DeleteButton},
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
                key: 'id_arb',
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
        let categoria = {
            id: id,
            is_active: boolean
        }
        this.$store.dispatch('categoria_partial_update', categoria)
            .then(() => {
                this.fetchCategorias();
            })
    },
    fetchCategorias() {
        this.$store.dispatch('fetchCategorias', this.filter_options)
        .then(() => {
            this.$store.commit('setLoading', false);
        })
    },
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