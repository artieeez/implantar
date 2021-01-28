<template>
  <div>
    <NavBar></NavBar>
    <b-container class='loginContainer'>
      <b-row align-h="center">
        <b-alert class='wrongCred' v-model="wrongCred" variant="danger" dismissible>
          Houve um problema ao autenticar! Por favor, tente novamente.
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
                placeholder="Enter email"
                required
              ></b-form-input>
            </b-form-group>

            <b-form-group id="input-group-2" label="Senha:" label-for="pass">
              <b-form-input
                id="pass"
                name='password'
                v-model="password"
                type='password'
                placeholder="Enter name"
                required
              ></b-form-input>
            </b-form-group>
            <b-button type="submit" variant="primary">Login</b-button>
          </b-form>
        </b-col>
      </b-row>
    </b-container>
  </div>
</template>

<script>
  import NavBar from '../components/Navbar'
  export default {
    name: 'Login',
    components: {
      NavBar
    },
    data () {
      return {
        username: '',
        password: '',
        wrongCred: false // activates appropriate message if set to true
      }
    },
    methods: {
      loginUser () { // call loginUSer action
        this.$store.dispatch('loginUser', {
          username: this.username,
          password: this.password
        })
            .then(() => {
              this.wrongCred = false
              this.$router.push({ name: 'home' })
            })
          .catch(err => {
            console.log(err)
            this.wrongCred = true // if the credentials were wrong set wrongCred to true
          })
        }
      }
  }
</script>

<style scoped>
.loginContainer {
  padding-top: 20vh;
}
.loginCol {
  background-color: white;
  padding: 30px 20px 30px 20px;
  border-radius: 8px;
  box-shadow: 2px 5px 5px 0px #d4d4d4;
}
.wrongCred {
  position: absolute;
  top: 80px;
}
</style>