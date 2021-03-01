<template>
  <div>
    <NavBar></NavBar>
    <b-container class='baseOuterCon1'>
        <h1 class='text-primary'>{{ rede.nome }}</h1>
        <div class="text-center text-primary my-2" v-show='$store.getters.isLoading'>
          <b-spinner class="align-middle"></b-spinner>
          <strong> Carregando...</strong>
        </div>
        <b-container class='baseCon1' v-show='!$store.getters.isLoading'>
            
        </b-container>
    </b-container>
  </div>
</template>

<script>
import NavBar from '../components/Navbar'

export default {
  name: "RedesDetail",
  components: {NavBar},
  data() {
    return {
        rede: {
          nome: "",
        },
        filter_options: {
            is_active: {
                in_use: true,
                value: true,
            }
        },
    };
  },
  computed: {
  },
  async beforeCreate() {
      this.$store.commit('setLoading', true);
  },
  async created() {
    this.fetchRedesDetail();
  },
  methods: {
    async fetchRedesDetail() {
        this.$store.dispatch('fetchRedesDetail', this.$route.params.redeId)
                .then((data) => {
                    this.rede = data;
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