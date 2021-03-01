<template>
  <div>
    <NavBar></NavBar>
    <b-container class='baseOuterCon1'>
        <h1 class='text-primary'>Cadastros</h1>
        <b-container class='baseCon1'>
            <b-table
                head-variant='light'
                fixed
                :busy="$store.getters.isLoading"
                striped
                hover
                small
                :borderless='false'
                :outlined='true'
                :items="items"
                :fields='fields'
                :select-mode="'range'"
                selectable
                @row-selected="onRowSelected"
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

                <template #cell(first_name)="data">
                    <span :class='{
                        "font-italic": !data.item.is_active,
                        "text-muted": !data.item.is_active,
                        }'>{{ data.value }}</span>
                </template>

                <template #cell(last_name)="data">
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
                            <b-col sm="2" class="text-sm-right"><b>Email:</b></b-col>
                            <b-col>{{ row.item.email }}</b-col>
                            <b-col sm="2" class="text-sm-right"><b>Ativo:</b></b-col>
                            <b-col>{{ row.item.is_active ? 'Ativo' : 'Inativo' }}</b-col>
                            <b-col sm="2" class="text-sm-right"><b>Redes:</b></b-col>
                            <b-col><div v-for='(rede, index) in row.item.redes' :key='index'>{{ rede.nome }}</div></b-col>
                        </b-row>
                        <b-row>
                            <b-button
                                variant="danger"
                                class='ml-2'
                                size='sm'
                                @click="user_active_change(row.item.id, !row.item.is_active)"
                                >
                                <span v-if='row.item.is_active'><b-icon-lock-fill/> Desativar usuário</span>
                                <span v-if='!row.item.is_active'><b-icon-unlock-fill/> Ativar usuário</span>
                                </b-button>
                        </b-row>
                    </b-card>
                </template>
            </b-table>
            <b-row>
                <b-col sm='6' md='3' lg='3'>
                    <b-button block size="sm" @click="clearSelected" class='mt-1'>Limpar seleção</b-button>
                </b-col>
                <b-col sm='6' md='3' lg='3' class='mt-1'>
                    <RegisterToken/>
                </b-col>
                <b-col sm='6' md='3' lg='3' class='mt-1'>
                    <b-form-checkbox
                        id="checkbox-1"
                        v-model="filter_options.is_active.in_use"
                        name="checkbox-1"
                        @change='fetchUsers()'
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
import RegisterToken from '../components/cadastros/RegisterToken'
import { mapState } from 'vuex'

export default {
  name: "Cadastros",
  components: {NavBar, RegisterToken},
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
                key: 'first_name',
                label: 'Nome',
                sortable: true,
            },
            {
                key: 'last_name',
                label: 'Sobrenome',
                sortable: true,
            },
            {
                key: 'groups[0].name',
                label: 'Grupo',
                sortable: true,
            },
            {
                key: 'profile.redes[0].nome',
                label: 'Redes',
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
      ...mapState(['users']),
      items() {
          let items = [];
          for (let i = 0; i < this.users.length; i++) {
              let row = this.users[i]
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
    this.fetchUsers();
  },
  methods: {
    onRowSelected(items) {
        this.selected = items
    },
    clearSelected() {
        this.$refs.selectableTable.clearSelected()
    },
    async user_active_change(id, boolean) {
        this.$store.commit('setLoading', true);
        let user = {
            id: id,
            data: {
                is_active: boolean
            }
        }
        this.$store.dispatch('user_partial_update', user)
                .then(() => {
                    this.fetchUsers();
                })
    },
    async fetchUsers() {
        this.$store.dispatch('fetchUsers', this.filter_options)
                .then(() => {
                    this.$store.commit('setLoading', false);
                })
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