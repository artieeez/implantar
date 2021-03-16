<template>
  <div>
    <NavBar></NavBar>
    <b-container class='baseOuterCon1'>
        <h1 class='text-primary'>Checklists</h1>
        <b-container class='baseCon1'>
            <ModelList
                modelName='categoria'
            />
            <hr>
            <ModelList
                modelName='itemBase'
            />
        </b-container>
    </b-container>
  </div>
</template>

<script>
import NavBar from '../components/Navbar'
import ModelList from '../components/checklists/ModelList'


export default {
  name: "Checklists",
  components: {NavBar, ModelList},
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