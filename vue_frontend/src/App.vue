<template>
  <div id="app">
    <router-view/>
  </div>
</template>

<style>
.bgRoxo {
  background-color: #b2a0cd;
  width: 100vw;
  min-height: 100vh;
  height: 100%;
}
.ErrPop1 {
  position: fixed;
  bottom: 20px;
  z-index: 200;
}
.FormCol1 {
  /* Uso
    <b-container>
      <b-row align-h="center">
        <b-col sm="12" md="8">
          <b-form @submit.prevent="registerUser" class="FormCol1">
  */
  background-color: white;
  padding: 30px 20px 30px 20px;
  border-radius: 8px;
  box-shadow: 2px 5px 5px 0px #998baf;
  margin: 0 0 20px 0;
}
.baseOuterCon1 {
  padding-top: 20px;
  padding-bottom: 20px;
}
.baseCon1 {
  background-color: white;
  border-radius: 8px;
  box-shadow: 2px 5px 5px 0px rgb(221, 221, 221);
  min-height: 200px;
  padding-top: 20px;
  padding-bottom: 20px;
  margin-top: 20px;
  margin-bottom: 20px;
}
</style>
