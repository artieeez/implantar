<template>
    <div class="loginLogoCon">
      <img class="loginLogo" :src="require('../../assets/logo2.png')" />
    </div>
</template>

<script>
  export default {
    name: 'LogoRoxo',
  }
</script>

<style scoped>
.loginLogoCon {
  display: flex;
  z-index: 0;
  width: 100%;
  justify-content: center;
}
.loginLogo {
  width: 170px;
}
@media (min-width: 1200px) {
  .loginLogoCon {
    padding-top: 10vh;
  } 
}
</style>