<template>
  <div>
    <NavBar></NavBar>
    <b-container class='baseOuterCon1'>
        <h1 class='text-primary'>Cadastros</h1>
        <b-container class='baseCon1'>
            <b-table
                head-variant='light'
                fixed
                :busy="isBusy"
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
                <template #cell(index)="data">
                    {{ data.index + 1 }}
                </template>
                <template #cell(show_details)="row">
                    <div class='actionCell'>
                        <b-button size="sm" @click="row.toggleDetails" class="mr-2">
                            <b-icon-arrow-down v-show='!row.detailsShowing'/>
                            <b-icon-arrow-up v-show='row.detailsShowing'/>
                        </b-button>
                    </div>
                </template>
                <template #row-details="row">
                    <b-card>
                        <b-row class="mb-2">
                            <b-col sm="3" class="text-sm-right"><b>Email:</b></b-col>
                            <b-col>{{ row.item.email }}</b-col>
                        </b-row>
                    </b-card>
                </template>
                <template #table-busy>
                    <div class="text-center text-primary my-2">
                    <b-spinner class="align-middle"></b-spinner>
                    <strong> Carregando...</strong>
                    </div>
                </template>
            </b-table>
            <b-row>
                <b-col sm='6' md='3' lg='3' class=''>
                    <b-button block size="sm" @click="clearSelected">Limpar seleção</b-button>
                </b-col>
                <b-col sm='6' md='3' lg='3'>
                    <RegisterToken/>
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
  name: "Register",
  components: {NavBar, RegisterToken},
  data() {
    return {
        isBusy: false,
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
            },
            {
                key: 'group',
                label: 'Grupo',
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
              row.is_active = false;
              items.push(row);
          }
          return items;
      },
  },
  async created() {
    // Observar as DUAS declarações async em 'created()' e na função anônima,
    // de forma que se evite um stack overflow.
    let success = false;
    let store = this.$store;
    do {
       await store.dispatch('fetchUsers')
            .then(() => {
                success = true; // Breaks do while
            })
            .catch(async err => { // 1* Função anônima async
                if (err.config && err.response && err.response.status === 401) { 
                    await store.dispatch('refreshToken') // attempt to obtain new access token by running 'refreshToken' action
                }
            })
    } while (!success);
  },
  methods: {
    onRowSelected(items) {
        this.selected = items
    },
    clearSelected() {
        this.$refs.selectableTable.clearSelected()
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