<template>
  <div class='painelBg'>
    <NavBar></NavBar>
    <b-container>
        <b-row class='painelRow'>
            <b-col sm='12' md='6'>
                <b-button :variant='painelButtont' class='painelButton'
                    :to='{ name:"checklists" }'>
                    <h4><span><b-icon-card-checklist/></span> Checklists</h4>
                </b-button>
            </b-col>
            <b-col sm='12' md='6'>
                <b-button :variant='painelButtont' class='painelButton'
                    :to='{ name:"cadastros" }'>
                    <h4><span><b-icon-person/></span> Cadastros</h4>
                </b-button>
            </b-col>
            <b-col sm='12' md='6'>
                <b-button :variant='painelButtont' class='painelButton'
                    :to='{ name:"redes" }'>
                    <h4><span><b-icon-building/></span> Redes</h4>
                </b-button>
            </b-col>
        </b-row>
    </b-container>
  </div>
</template>

<script>
  import NavBar from '../components/Navbar'
  export default {
    name: 'Painel',
    components: {
      NavBar
    },
    data () {
      return {
          painelButtont: 'primary',
      }
    },
  }
</script>

<style scoped>
.painelRow {
    padding: 20px 0 20px 0;
}
.painelButton {
    border-radius: 6px;
    height: 100px;
    width: 100%;
    color: whitesmoke;
    display: flex;
    justify-content: center;
    align-items: center;
    margin: 10px 0 10px 0;
    box-shadow: 2px 5px 5px 0px #d4d4d4;
}
@media (min-width: 768px) {
    .painelButton {
        height: 150px;
        margin: 10px 0 10px 0;
    }
}
.painelBg {
    margin: 0;
    padding: 0;
    background-color: whitesmoke;
    width: 100vw;
    min-height: 100vh;
    height: 100%;
  }
</style>