<template>
<div>
  <b-navbar toggleable="lg" type="dark" variant="primary">
    <b-navbar-brand href="/">Implantar</b-navbar-brand>

    <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>

    <b-collapse id="nav-collapse" is-nav>
      <b-navbar-nav>
        <b-nav-item :to='{ name:"painel" }' v-if="accessToken!=null">Painel</b-nav-item>
        <b-nav-item :to="{ name:'sobre' }" exact>Sobre</b-nav-item>
      </b-navbar-nav>

      <!-- Right aligned nav items -->
      <b-navbar-nav class="ml-auto" v-if="accessToken!=null">
        <b-nav-item-dropdown right>
          <!-- Using 'button-content' slot -->
          <template #button-content>
            <em>{{ getUserProfile != null ? getUserProfile.first_name : 'Usuário' }} </em>
          </template>
          <b-dropdown-item :to="{ name:'logout' }" v-if="accessToken!=null">Sair</b-dropdown-item>
        </b-nav-item-dropdown>
      </b-navbar-nav>
    </b-collapse>
  </b-navbar>
</div>
</template>

<script>
  import { mapGetters } from 'vuex'
  export default {
    name: 'NavBar',
    computed: {
      ...mapGetters(['accessToken', 'getUserProfile']),
    }
  }
</script>

<style scoped>
</style>