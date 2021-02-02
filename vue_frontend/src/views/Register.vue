<template>
  <div class="loginBg">
    <div class="loginLogoCon">
      <img class="loginLogo" :src="require('../assets/logo2.png')" />
    </div>
    <b-container class="loginContainer">
      <b-row align-h="center">
        <b-alert
          class="wrongCred"
          v-model="wrongCred"
          variant="danger"
          dismissible
        >
          Houve um problema com o seu cadastro! Por favor, tente novamente.
        </b-alert>
        <b-alert
          class="wrongCred"
          v-model="expiredRegisterToken"
          variant="danger"
        >
          Ops! Parece que o seu link de acesso expirou. Peça um novo para um representante.
        </b-alert>
        <b-col sm="12" md="8">
          <b-form @submit.prevent="registerUser" class="loginCol">
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

export default {
  name: "Register",
  components: {},
  data() {
    return {
      USERNAME_LENGTH: 6,
      PASSWORD_LENGTH: 6,
      FIRSTNAME_LENGTH: 2,
      LASTNAME_LENGTH: 2,
      username: "",
      password: "",
      passwordConfirm: "",
      firstName: "",
      lastName: "",
      email: "",
      expiredRegisterToken: false,
      wrongCred: false,
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
        }
        return this.username.length >= this.USERNAME_LENGTH;
    },
    invalidUsernameFeedback() {
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
              this.wrongCred = false
              this.$router.push({ name: 'painel' })
            })
          .catch(err => {
            this.err = err;
            this.wrongCred = true // if the credentials were wrong set wrongCred to true
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
                this.wrongCred = true;
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
                if (response.data.code == "200") {
                    this.expiredRegisterToken = false;
                    resolve(true);
                } else
                this.expiredRegisterToken = true;
                resolve(false);
            })
            .catch(err => {
                reject(err) // error generating new access and refresh token because refresh token has expired
            })
        })
    },
  },
};
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