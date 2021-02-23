import Vue from 'vue'
import Vuex from 'vuex'
import { axiosBase } from '../api/axios-base'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    loading: false,
    accessToken: localStorage.getItem('access_token') || null, // makes sure the user is logged in even after
    // refreshing the page
    refreshToken: localStorage.getItem('refresh_token') || null,
    userProfile: JSON.parse(localStorage.getItem('user_profile')) || null,
    register_token: () => {
      var url_string = window.location.href; //window.location.href
      var url = new URL(url_string);
      var c = url.searchParams.get("register-token");
      return c},
    dbVersion: localStorage.getItem('db_version') || null,
    redes: [],
    users: [],
    groups: [],
  },
  getters: {
    isLoading (state) {
      return state.loading;
    },
    accessToken (state) {
      return state.accessToken;
    },
    getUserProfile (state) {
      return state.userProfile;
    },
    getGroups (state) {
      return state.groups;
    },
    getRedes (state) {
      return state.redes;
    },
    // Permissions
    isOperador (state) {
      for (let i = 0; i < state.userProfile.groups.length; i++) {
        if (state.userProfile.groups[i].name === 'operador') {
          return true;
        }
      }
      return false;
    },
    isAuthenticated (state) {
      return (state.accessToken != null && state.userProfile != null)
    },
    hasRegisterToken (state) {
      return state.register_token() != null
    },
  },
  mutations: {
    setLoading (state, boolean) {
      state.loading = boolean;
    },
    updateLocalStorage (state, { access, refresh }) {
      localStorage.setItem('access_token', access)
      localStorage.setItem('refresh_token', refresh)
      state.accessToken = access
      state.refreshToken = refresh
    },
    updateAccess (state, access) {
      state.accessToken = access
      localStorage.setItem('access_token', access)
    },
    destroyUserAuth (state) {
      state.accessToken = null
      state.refreshToken = null
      state.userProfile = null
    },
    updateDbVersion (state, dbVersion) {
      state.dbVersion = dbVersion;
      localStorage.setItem('db_version', JSON.stringify(dbVersion))
    },
    updateRedes (state, redes) {
      state.redes = redes;
      /* localStorage.setItem('redes', JSON.stringify(redes)) */
    },
    updateGroups (state, groups) {
      state.groups = groups;
      /* localStorage.setItem('users', JSON.stringify(users)) */
    },
    updateUsers (state, users) {
      state.users = users;
      /* localStorage.setItem('users', JSON.stringify(users)) */
    },
    updateUserProfile (state, userProfile) {
      state.userProfile = userProfile;
      localStorage.setItem('user_profile', JSON.stringify(userProfile))
    },
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
      if (context.getters.isAuthenticated) {
        return new Promise((resolve) => {
          axiosBase.post('/token/logout/')
            .then(() => {
              localStorage.removeItem('access_token')
              localStorage.removeItem('refresh_token')
              localStorage.removeItem('user_profile')
              context.commit('destroyUserAuth')
            })
            .catch(err => {
              localStorage.removeItem('access_token')
              localStorage.removeItem('refresh_token')
              localStorage.removeItem('user_profile')
              context.commit('destroyUserAuth')
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
        axiosBase.get('/users/my_profile', {
          headers: { Authorization: `Bearer ${context.state.accessToken}` },
        })
          .then(response => {
            context.commit('updateUserProfile', response.data)
            resolve()
          })
          .catch(err => {
            reject(err)
          })
      })
    },
    user_partial_update (context, user) {
      return new Promise((resolve, reject) => {
        axiosBase.patch(`/users/${user.id}/`, user.data,
        {
          headers: { Authorization: `Bearer ${context.state.accessToken}` },
        })
          .then(response => {
            resolve(response)
          })
          .catch(err => {
            reject(err)
          })
      })
    },
    postRegisterToken (context, data) {
      return new Promise((resolve, reject) => {
        console.log(data);
        axiosBase.post(`/register_token/`, {
          group: data.group,
          redes: data.redes
        },
        {
          headers: { Authorization: `Bearer ${context.state.accessToken}` },
        })
          .then(response => {
            resolve(response)
          })
          .catch(err => {
            reject(err)
          })
      })
    },
    fetchDbVersion (context) {
      return new Promise((resolve, reject) => {
        axiosBase.get('/get_version', {
          headers: { Authorization: `Bearer ${context.state.accessToken}` },
        })
          .then(response => {
            context.commit('updateDbVersion', response.data.version)
            resolve(response.data.version)
          })
          .catch(err => {
            reject(err)
          })
      })
    },
    fetchGroups (context) {
      let searchUrl = '/groups'
      return new Promise((resolve, reject) => {
        axiosBase.get(searchUrl, {
          headers: { Authorization: `Bearer ${context.state.accessToken}` },
        })
          .then(response => {
            context.commit('updateGroups', response.data.results)
            resolve(response.data.results)
          })
          .catch(err => {
            reject(err)
          })
      })
    },
    fetchUsers (context, filter_options) {
      let searchUrl = '/users'
      if (filter_options.is_active.in_use) {
        let str_is_active = `?is_active=${filter_options.is_active.value}`
        searchUrl += str_is_active
      }
      return new Promise((resolve, reject) => {
        axiosBase.get(searchUrl, {
          headers: { Authorization: `Bearer ${context.state.accessToken}` },
        })
          .then(response => {
            context.commit('updateUsers', response.data.results)
            resolve(response.data.results)
          })
          .catch(err => {
            reject(err)
          })
      })
    },
    fetchRedes (context) {
      return new Promise((resolve, reject) => {
        axiosBase.get('/redes', {
          headers: { Authorization: `Bearer ${context.state.accessToken}` },
        })
          .then(response => {
            context.commit('updateRedes', response.data.results)
            resolve(response.data.results)
          })
          .catch(err => {
            reject(err)
          })
      })
    },
  }
})
