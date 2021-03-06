import Vue from 'vue'
import VueRouter from 'vue-router'
import Painel from '../views/Painel.vue'
import Checklists from '../views/Checklists.vue'
import Redes from '../views/Redes.vue'
import RedesDetail from '../views/RedesDetail.vue'
import Cadastros from '../views/Cadastros.vue'
import Login from '../views/Login.vue'
import Register from '../views/Register.vue'
import Logout from '../views/Logout'
import Sobre from '../views/Sobre'

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
      requiresOperador: true
    }
  },
  {
    path: '/redes',
    name: 'redes',
    component: Redes,
    meta: {
      requiresAuth: true,
      requiresOperador: true
    }
  },
  {
    path: '/redes/:redeId',
    name: 'redes-details',
    component: RedesDetail,
    meta: {
      requiresAuth: true,
      requiresAssignment: true
    }
  },
  {
    path: '/cadastros',
    name: 'cadastros',
    component: Cadastros,
    meta: {
      requiresAuth: true,
      requiresOperador: true
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
    path: '/register',
    name: 'register',
    component: Register,
    meta: {
      requiresLogged: true,
      requiresRegisterToken: true,
    }
  },
  {
    path: '/logout',
    name: 'logout',
    component: Logout,
    meta: {
      requiresAuth: true
    }
  },
  {
    path: '/sobre',
    name: 'sobre',
    component: Sobre,
    meta: {
      requiresAuth: false
    }
  },
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
