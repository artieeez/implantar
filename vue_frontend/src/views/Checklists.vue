<template>
  <div>
    <NavBar></NavBar>
    <b-container>
        
    </b-container>
  </div>
</template>

<script>
  import NavBar from '../components/Navbar'
  export default {
    name: 'Checklists',
    components: {
      NavBar
    },
    data () {
      return {
          buttonVariant: 'primary',
      }
    },
  }
</script>

<style scoped>

@media (min-width: 768px) {

}
</style>