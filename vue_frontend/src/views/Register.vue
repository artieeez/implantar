<template>
  <div class='bgRoxo'>
    <LogoRoxo/>
    <b-container>
      <b-row align-h="center">
        <b-alert
          class="ErrPop1"
          v-model="ErrPop1"
          variant="danger"
          dismissible
        >
          Houve um problema com o seu cadastro! Por favor, tente novamente.
        </b-alert>
        <b-alert
          class="ErrPop1"
          v-model="expiredRegisterToken"
          variant="danger"
        >
          Ops! Parece que o seu link de acesso expirou. Peça um novo para um representante.
        </b-alert>
        <b-col sm="12" md="8">
          <b-form @submit.prevent="registerUser" class="FormCol1">
            <b-form-group
              id="input-group-1"
              label="Nome de usuário:"
              label-for="user"
              :state="invalidUsername"
              :invalid-feedback="invalidUsernameFeedback"
            >
              <b-form-input
                id="user"
                name="username"
                v-model="username"
                type="text"
                placeholder="Digite seu nome de usuário"
                :state="invalidUsername"
                :disabled='expiredRegisterToken'
                required
              ></b-form-input>
            </b-form-group>
            <b-row>
              <b-col sm="12" md="6">
                <b-form-group
                  id="input-group-2"
                  label="Senha:"
                  label-for="password"
                  :state="invalidPassword"
                >
                  <b-form-input
                    id="password"
                    name="password"
                    v-model="password"
                    type="password"
                    placeholder="Escolha uma senha"
                    :state="invalidPassword"
                    :disabled='expiredRegisterToken'
                    required
                  ></b-form-input>
                </b-form-group>
              </b-col>
              <b-col sm="12" md="6">
                <b-form-group
                  id="input-group-3"
                  label="Confirme sua senha:"
                  label-for="passwordConfirm"
                  :state="invalidPassword"
                  :invalid-feedback="invalidPasswordFeedback"
                >
                  <b-form-input
                    id="passwordConfirm"
                    name="passwordConfirm"
                    v-model="passwordConfirm"
                    type="password"
                    :state="invalidPassword"
                    :disabled='expiredRegisterToken'
                    required
                  ></b-form-input>
                </b-form-group>
              </b-col>
            </b-row>
            <b-row>
                <b-col sm='12' md='4'>
                    <b-form-group
                        id="input-group-4"
                        label="Nome:"
                        label-for="input-firstName"
                        :state="invalidFirstName"
                        :invalid-feedback="invalidFirstNameFeedback">
                        <b-form-input
                            id='input-firstName'
                            name='input-firstName'
                            v-model='firstName'
                            type='text'
                            :state='invalidFirstName'
                            :disabled='expiredRegisterToken'
                            required>
                        </b-form-input>
                    </b-form-group>
                </b-col>
                <b-col sm='12' md='8'>
                    <b-form-group
                        id="input-group-5"
                        label="Sobrenome:"
                        label-for="input-lastName"
                        :state="invalidLastName"
                        :invalid-feedback="invalidLastNameFeedback">
                        <b-form-input
                            id='input-lastName'
                            name='input-lastName'
                            v-model='lastName'
                            type='text'
                            :state='invalidLastName'
                            :disabled='expiredRegisterToken'
                            required>
                        </b-form-input>
                    </b-form-group>
                </b-col>
            </b-row>
            <b-form-group
              id="input-group-6"
              label="Email:"
              label-for="email"
              :state="invalidEmail"
              :invalid-feedback="invalidEmailFeedback"
            >
              <b-form-input
                id="email"
                name="email"
                v-model="email"
                type="email"
                placeholder="Digite seu email"
                :state="invalidEmail"
                :disabled='expiredRegisterToken'
                required
              ></b-form-input>
            </b-form-group>
            <b-button type="submit" variant="primary"
                :disabled='isFormReady'
              >Próximo</b-button
            >
          </b-form>
        </b-col>
      </b-row>
    </b-container>
  </div>
</template>

<script>
import { axiosBase, APIEndpoints } from '../api/axios-base'
import LogoRoxo from '../components/bg/LogoRoxo.vue'


export default {
  name: "Register",
  components: {LogoRoxo},
  data() {
    return {
      USERNAME_LENGTH: 6,
      PASSWORD_LENGTH: 6,
      FIRSTNAME_LENGTH: 2,
      LASTNAME_LENGTH: 2,
      username: "",
      username_in_use: false,
      password: "",
      passwordConfirm: "",
      firstName: "",
      lastName: "",
      email: "",
      expiredRegisterToken: false,
      ErrPop1: false,
      wrongRegister: false,
      hidePassword: true,
      err: null,
    };
  },
  created() {
      this.verifyRegisterToken();
  },
  computed: {
    registerToken() {
        var url_string = window.location.href;
        var url = new URL(url_string);
        var c = url.searchParams.get("register-token");
        return c
    },
    invalidUsername() {
        if (this.username == '') {
          return null
        } else if (this.username.length < this.USERNAME_LENGTH) {
          return false
        } else {
          this.is_username_in_use(); // Altera is_username_in_use de forma async
          return !this.username_in_use;
        }
    },
    invalidUsernameFeedback() {
      if (this.username_in_use) {
        return `Nome de usuário indisponível`;
      }
      return `O nome de usuário deve conter pelo menos ${this.USERNAME_LENGTH} 
      caracteres.`;
    },
    invalidPassword() {
        if (this.password == '') {
            return null
        } else if (this.password.length < this.PASSWORD_LENGTH) {
            return false;
        }
        return this.password == this.passwordConfirm;
    },
    invalidPasswordFeedback() {
        if (this.password.length < this.PASSWORD_LENGTH) {
            return `A senha deve conter pelo menos ${this.PASSWORD_LENGTH}
            caracteres.`;
        }
        return 'Confirme a sua senha';
    },
    isFormReady() {
        return !(
            this.invalidUsername &&
            this.invalidPassword &&
            this.invalidFirstName &&
            this.invalidLastName &&
            this.invalidEmail &&
            !this.expiredRegisterToken);
    },
    invalidFirstName() {
        if (this.firstName == '') {
            return null
        }
        return this.firstName.length >= this.FIRSTNAME_LENGTH;
    },
    invalidFirstNameFeedback() {
      return `Escreva o seu nome.`;
    },
    invalidLastName() {
        if (this.lastName == '') {
            return null
        }
        return this.lastName.length >= this.LASTNAME_LENGTH;
    },
    invalidLastNameFeedback() {
      return `Escreva o seu sobrenome.`;
    },
    invalidEmail() {
        if (this.email == '') {
            return null
        }
        const re = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(String(this.email).toLowerCase());
    },
    invalidEmailFeedback() {
      return `Insira um email válido.`;
    },
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
            this.err = err;
            this.ErrPop1 = true // if the credentials were wrong set ErrPop1 to true
        })
    },
    registerUser() {
      return new Promise((resolve, reject) => {
        // send the username and password to the backend API:
        axiosBase.post('/users/?register-token=' + this.registerToken, {
          username: this.username,
          password: this.password,
          first_name: this.firstName,
          last_name: this.lastName,
          email: this.email,
        })
        // if successful update local storage:
          .then(response => {
              if (response.status == 201) {
                this.loginUser();
              } else {
                this.ErrPop1 = true;
              }
            resolve()
          })
          .catch(err => {
            reject(err)
          })
      })
    },
    verifyRegisterToken() {
        return new Promise((resolve, reject) => {
            axiosBase.get(
                APIEndpoints.verifyRegisterToken + '/' +
                this.registerToken, {
            })
            .then(response => {
                if (response.status == "200") {
                    this.expiredRegisterToken = false;
                    resolve(true);
                } else {
                  this.expiredRegisterToken = true;
                  resolve(false);
                }
            })
            .catch(err => {
                this.expiredRegisterToken = true;
                reject(err) // error generating new access and refresh token because refresh token has expired
            })
        })
    },
    is_username_in_use() {
        // Altera is_username_in_use de forma async
        let username = this.username;
            axiosBase.get(
                APIEndpoints.is_username_in_use + '/' +
                username + '?register-token=' + this.registerToken, {
            })
            .then(response => {
                console.log(response);
                if (response.status == "204") {
                  this.username_in_use = false;
                  return true;
                } else {
                  this.username_in_use = true;
                  return false;
                }
            })
            .catch(() => {
                this.username_in_use = true;
                return false // error generating new access and refresh token because refresh token has expired
            })
    },
  },
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