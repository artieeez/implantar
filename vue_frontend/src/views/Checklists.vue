<template>
  <div>
    <NavBar></NavBar>
    <b-container class='baseOuterCon1'>
        <h1 class='text-primary'>Checklists</h1>
        <b-container class='baseCon1'>
            <Categoria/>
            <ItemBase/>
        </b-container>
    </b-container>
  </div>
</template>

<script>
import NavBar from '../components/Navbar'
import { mapState } from 'vuex'
import Categoria from '../components/checklists/Categoria'
import ItemBase from '../components/checklists/ItemBase'


export default {
  name: "Checklists",
  components: {NavBar, Categoria, ItemBase},
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
        this.$store.dispatch('fetchRedes', this.filter_options)
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
</style>