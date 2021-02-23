import Vue from 'vue'
import '@babel/polyfill'
import 'mutationobserver-shim'
import './plugins/bootstrap-vue'
import App from './App.vue'
import router from './router'
import store from './store'
import IdleVue from 'idle-vue'

Vue.config.productionTip = false

const eventsHub = new Vue()

Vue.use(IdleVue, {
  eventEmitter: eventsHub,
  idleTime: 720000
}) // sets up the idle time,i.e. time left to logout the user on no activity
Vue.config.productionTip = false

router.beforeEach((to, from, next) => {
  // Autenticação
  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!store.getters.isAuthenticated) {
      next({ name: 'login' })
    } else {
      // Permissão Operador
      if (to.matched.some(record => record.meta.requiresOperador)) {
        if (store.getters.isOperador) {
          next()
        } else {
          next({ name: 'painel' })
        }
      // Permissão Assignment/ relacionado à rede
      } else if (to.matched.some(record => record.meta.requiresAssignment)) {
        if (store.getters.isOperador) {
          next()
        } else {
          if (store.getters.getUserProfileRedesIdList.includes(parseInt(to.params.redeId))) {
            next()
          } else {
            next({ name: 'painel' })
          }
        }
      } else {
        next()
      }
    }
  } else if (to.matched.some(record => record.meta.requiresLogged)) {
    if (store.getters.isAuthenticated) {
      next({ name: 'painel' })
    } else {
      // Possui register Token
      if (to.matched.some(record => record.meta.requiresRegisterToken)) {
        if (store.getters.hasRegisterToken) {
          next()
        } else {
          next({ name: 'login' })
        }
      } else {
        next()
      }
    }
  } else {
    next()
  }
})

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
