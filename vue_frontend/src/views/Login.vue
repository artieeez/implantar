<template>
  <div class='loginBg'>
    <div class='loginLogoCon'>
      <img class='loginLogo' :src="require('../assets/logo2.png')"/>
    </div>
    <b-container class='loginContainer'>
      <b-row align-h="center">
        <b-alert class='wrongCred' v-model="wrongCred" variant="danger" dismissible>
          Houve um problema ao autenticar! Por favor, tente novamente. {{ err }}
        </b-alert>
        <b-col  sm='12' md='8'>
          <b-form @submit.prevent="loginUser" class='loginCol'>
            <b-form-group
              id="input-group-1"
              label="Login:"
              label-for="user"
            >
              <b-form-input
                id="user"
                name='username'
                v-model="username"
                type="text"
                placeholder="Digite seu nome de usuário"
                required
              ></b-form-input>
            </b-form-group>
            <b-form-group id="input-group-2" label="Senha:" label-for="pass">
              <b-input-group id="input-group-2" label="Senha:" label-for="pass">
              <template #append >
                <b-input-group-text>
                  <b-icon-eye v-if='hidePassword' 
                    @click='hidePassword = false' 
                    class='hidePass'/>
                  <b-icon-eye-slash-fill v-if='!hidePassword' 
                    @click='hidePassword = true'
                    class='hidePass'/>
                </b-input-group-text>
              </template>
              <b-form-input
                id="pass"
                name='password'
                v-model="password"
                :type='hidePassword ? "password" : "text"'
                placeholder="Digite sua senha"
                required
              ></b-form-input>
            </b-input-group>
            </b-form-group>
            <b-button type="submit" class='loginButton' variant="primary">Entrar</b-button>
          </b-form>
        </b-col>
      </b-row>
    </b-container>
  </div>
</template>

<script>
  export default {
    name: 'Login',
    components: {
    },
    data () {
      return {
        username: '',
        password: '',
        wrongCred: false, // activates appropriate message if set to true
        hidePassword: true,
        err: null,
      }
    },
    methods: {
      loginUser () { // call loginUSer action
        this.$store.dispatch('loginUser', {
          username: this.username,
          password: this.password,
        })
            .then(() => {
              this.wrongCred = false
              this.$router.push({ name: 'painel' })
            })
          .catch(err => {
            console.log(err)
            this.err = err;
            this.wrongCred = true // if the credentials were wrong set wrongCred to true
          })
        }
      }
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
  width: 180px;
}
.wrongCred {
  position: absolute;
  bottom: 20px;
  z-index: 200;
}
@media (min-width: 768px) {
}
@media (min-width: 992px) {
}
@media (min-width: 1200px) {
  .loginLogoCon {
    padding-top: 10vh;
  } 
}
.loginCol {
  background-color: white;
  padding: 30px 20px 30px 20px;
  border-radius: 8px;
  box-shadow: 2px 5px 5px 0px #998baf;
}
.loginBg {
  background-color: #b2a0cd;
  width: 100vw;
  height: 100vh;
}
</style>