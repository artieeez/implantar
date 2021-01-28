<template>
  <div class="home">
    <NavBar></NavBar>
    <b-container>
      <b-row>
        <b-col class='homeCol' sm='12' md='6' lg='3'><b-container class='homeCon'><h1>1</h1></b-container></b-col>
        <b-col class='homeCol' sm='12' md='6' lg='3'><b-container class='homeCon'><h1>2</h1></b-container></b-col>
        <b-col class='homeCol' sm='12' md='6' lg='3'><b-container class='homeCon'><h1>3</h1></b-container></b-col>
        <b-col class='homeCol' sm='12' md='6' lg='3'><b-container class='homeCon'><h1>4</h1></b-container></b-col>
      </b-row>
    </b-container>
  </div>
</template>

<script>
  import NavBar from '../components/Navbar'
  export default {
    name: 'Home',
    components: {
      NavBar
    },
    computed: {
      teste: function() {
        return 'haha';
      }
    }
  }
</script>

<style scoped>
  .homeCol {
    background-color: antiquewhite;
    padding: 10px;
  }
  .homeCon {
    background-color: azure;
    display: flex;
    align-content: center;
    justify-content: center;
  }
</style>