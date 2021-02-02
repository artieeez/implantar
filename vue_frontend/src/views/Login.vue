<template>
  <div class='bgRoxo'>
    <LogoRoxo/>
    <b-container class='loginContainer'>
      <b-row align-h="center">
        <b-alert class='ErrPop1' v-model="ErrPop1" variant="danger" dismissible>
          Houve um problema ao autenticar! Por favor, tente novamente. {{ err }}
        </b-alert>
        <b-col  sm='12' md='8'>
          <b-form @submit.prevent="loginUser" class='FormCol1'>
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
  import LogoRoxo from '../components/bg/LogoRoxo.vue'

  export default {
    name: 'Login',
    components: {
      LogoRoxo
    },
    data () {
      return {
        username: '',
        password: '',
        ErrPop1: false, // activates appropriate message if set to true
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
              this.ErrPop1 = false
              this.$router.push({ name: 'painel' })
            })
          .catch(err => {
            console.log(err)
            this.err = err;
            this.ErrPop1 = true // if the credentials were wrong set ErrPop1 to true
          })
        }
      }
  }
</script>

<style scoped>
@media (min-width: 768px) {
}
@media (min-width: 992px) {
}
@media (min-width: 1200px) {
}
</style>