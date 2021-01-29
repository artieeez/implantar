import Vue from 'vue'
import VueRouter from 'vue-router'
import Painel from '../views/Painel.vue'
import Checklists from '../views/Checklists.vue'
import Redes from '../views/Redes.vue'
import Cadastros from '../views/Cadastros.vue'
import Login from '../views/Login.vue'
import Logout from '../views/Logout'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'painel',
    component: Painel,
    meta: {
      requiresAuth: true
    }
  },
  {
    path: '/checklists',
    name: 'checklists',
    component: Checklists,
    meta: {
      requiresAuth: true,
      requiresPermission: true
    }
  },
  {
    path: '/redes',
    name: 'redes',
    component: Redes,
    meta: {
      requiresAuth: true,
      requiresPermission: true
    }
  },
  {
    path: '/cadastros',
    name: 'cadastros',
    component: Cadastros,
    meta: {
      requiresAuth: true,
      requiresPermission: true
    }
  },
  {
    path: '/login',
    name: 'login',
    component: Login,
    meta: {
      requiresLogged: true
    }
  },
  {
    path: '/logout',
    name: 'logout',
    component: Logout,
    meta: {
      requiresAuth: true
    }
  }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
