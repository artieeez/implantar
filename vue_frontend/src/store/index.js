import Vue from 'vue'
import Vuex from 'vuex'
import { axiosBase } from '../api/axios-base'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    accessToken: localStorage.getItem('access_token') || null, // makes sure the user is logged in even after
    // refreshing the page
    refreshToken: localStorage.getItem('refresh_token') || null,
    register_token: () => {
      var url_string = window.location.href; //window.location.href
      var url = new URL(url_string);
      var c = url.searchParams.get("register-token");
      return c},
    loading: false,
    userProfile: JSON.parse(localStorage.getItem('user_profile')) || null,
  },
  getters: {
    loggedIn (state) {
      // TODO incluir user
      return state.accessToken != null
    },
    hasRegisterToken (state) {
      return state.register_token() != null
    },
    accessToken (state) {
      return state.accessToken;
    },
    getUserProfile (state) {
      return state.userProfile;
    }
  },
  mutations: {
    updateLocalStorage (state, { access, refresh }) {
      localStorage.setItem('access_token', access)
      localStorage.setItem('refresh_token', refresh)
      state.accessToken = access
      state.refreshToken = refresh
    },
    updateAccess (state, access) {
      state.accessToken = access
    },
    destroyToken (state) {
      state.accessToken = null
      state.refreshToken = null
    },
    updateUserProfile (state,{userProfile}) {
      state.userProfile = userProfile;
      localStorage.setItem('user_profile', JSON.stringify(userProfile))
    },
    destroyUserProfile (state) {
      state.userProfile = null
    }
  },
  actions: {
    // run the below action to get a new access token on expiration
    refreshToken (context) {
      return new Promise((resolve, reject) => {
        axiosBase.post('/token/refresh/', {
          refresh: context.state.refreshToken
        }) // send the stored refresh token to the backend API
          .then(response => { // if API sends back new access and refresh token update the store
            console.log('New access successfully generated')
            context.commit('updateAccess', response.data.access)
            resolve(response.data.access)
          })
          .catch(err => {
            console.log('error in refreshToken Task')
            reject(err) // error generating new access and refresh token because refresh token has expired
          })
      })
    },
    logoutUser (context) {
      if (context.getters.loggedIn) {
        return new Promise((resolve) => {
          axiosBase.post('/token/logout/')
            .then(() => {
              localStorage.removeItem('access_token')
              localStorage.removeItem('refresh_token')
              localStorage.removeItem('user_profile')
              context.commit('destroyToken')
            })
            .catch(err => {
              localStorage.removeItem('access_token')
              localStorage.removeItem('refresh_token')
              localStorage.removeItem('user_profile')
              context.commit('destroyToken')
              resolve(err)
            })
        })
      }
    },
    loginUser (context, credentials) {
      return new Promise((resolve, reject) => {
        // send the username and password to the backend API:
        axiosBase.post('/token/', {
          username: credentials.username,
          password: credentials.password
        })
        // if successful update local storage:
          .then(response => {
            context.commit('updateLocalStorage', { access: response.data.access, refresh: response.data.refresh }) // store the access and refresh token in localstorage
            context.dispatch('fetchUserProfile').then(() => {
              resolve()
            })
          })
          .catch(err => {
            reject(err)
          })
      })
    },
    fetchUserProfile (context) {
      return new Promise((resolve, reject) => {
        // send the username and password to the backend API:
        axiosBase.get('/users/my_profile', {
          headers: { Authorization: `Bearer ${context.state.accessToken}` },
        })
        // if successful update local storage:
          .then(response => {
            context.commit('updateUserProfile', {userProfile: response.data}) // store the access and refresh token in localstorage
            resolve()
          })
          .catch(err => {
            reject(err)
          })
      })
    }
  }
})
