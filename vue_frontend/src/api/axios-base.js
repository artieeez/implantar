import axios from 'axios'
import store from '../store'
const APIUrl = 'http://0.0.0.0/api'

const APIEndpoints = {
  verifyRegisterToken: '/register_token/verify',
  is_username_in_use: '/users/is_username_in_use',
  is_categoria_in_use: '/categorias/is_categoria_in_use',
}

const axiosBase = axios.create({
  baseURL: APIUrl,
  headers: { 
    contentType: 'application/json',
  }
})
axiosBase.interceptors.response.use(function (response) {
  return response;
}, function (err) {
  // if error response status is 401, it means the request was invalid due to expired access token
  return new Promise(function (resolve, reject) {
    if (err.config && err.response && err.response.status === 401) {
      console.log("Interceptor - 1 <<<<<<<<  |  >>>>>>>");
      store.dispatch('refreshToken') // attempt to obtain new access token by running 'refreshToken' action
        .then(access => {
          console.log("Interceptor - 2 - got acess key");
          err.config.headers.Authorization = `Bearer ${access}`;
          console.log("Interceptor - 4 - retrying request");
          axios.request(
            err.config,
          ).then(response => {
            console.log("Interceptor - 5 - successfully got data with new token");
            resolve(response);
          }).catch(err => {
            console.log('Got the new access token but error while trying to fetch data from the API using it')
            reject(err);
          })
        })
        .catch(err => {
          reject(err);
        })
    } else {
      reject(err);
    }
  })
})

const axiosRefreshTokenBase = axios.create({
  baseURL: APIUrl,
  headers: { 
    contentType: 'application/json',
  }
})

export { axiosBase, axiosRefreshTokenBase, APIEndpoints }
