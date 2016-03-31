'use strict'

import replace from 'lodash/replace'
import get from 'lodash/get'
import merge from 'lodash/merge'
import { deleteAllTokens, readCookie, isTokenExpired } from './token.js'
import { TC_JWT, AUTH0_REFRESH, AUTH0_JWT, V2_SSO, V2_COOKIE, API_URL, AUTH0_DOMAIN, AUTH0_CLIENT_ID } from './constants.js'
import fetch from 'isomorphic-fetch'

function AuthException(params) {
  Object.assign(this, params)
}

function fetchJSON(url, options) {
  const config = merge({
    headers: {
      'Content-Type': 'application/json;charset=UTF-8'
    }
  }, options)

  if (config.body) config.body = JSON.stringify(config.body)

  function handleResponse(response) {
    return response.json()
      .then( json => {

        // All v3 apis *should* have a result object
        if (json.result) {

          // If the nested status is ok, return the parsed JSON
          if (json.result.status >= 200 && json.result.status < 300) {
            return json
          } else {
            throw new AuthException({
              message: json.result.content,
              response
            })
          }

        // If this is a non v3 response but still ok
        } else if (response.status >= 200 && response.status < 300) {
          return json
        } else {
          throw new AuthException({
            message: response.statusText,
            response
          })
        }
      })
  }

  return fetch(url, config).then( handleResponse )
}

export function isLoggedIn() {
  return localStorage.getItem(TC_JWT) !== null
}

export function getToken() {
  return localStorage.getItem(TC_JWT)
}

export function logout() {
  const jwt = localStorage.getItem(TC_JWT) || ''
  const url = API_URL + '/v3/authorizations/1'
  const config = {
    method: 'DELETE',
    headers: {
      Authorization: 'Bearer ' + jwt
    }
  }

  return fetchJSON(url, config)
    .then(deleteAllTokens)
    .catch(console.error)
}

function auth0Signin(options) {
  const url = 'https://' + AUTH0_DOMAIN + '/oauth/ro'
  const config = {
    method: 'POST',
    body: {
      username: options.username,
      password: options.password,
      client_id: AUTH0_CLIENT_ID,
      sso: false,
      scope: 'openid profile offline_access',
      response_type: 'token',
      connection: options.connection || 'LDAP',
      grant_type: 'password',
      device: 'Browser'
    }
  }

  return fetchJSON(url, config)
}

function setAuth0Tokens({id_token, refresh_token}) {
  if (id_token === undefined || refresh_token === undefined) {
    throw new AuthException({
      message: 'Unable to contact login server',
      reason: 'Auth0 response did not contain proper tokens',
      id_token,
      refresh_token
    })
  }

  localStorage.setItem(AUTH0_JWT, id_token)
  localStorage.setItem(AUTH0_REFRESH, refresh_token)
}

function getNewJWT() {
  const externalToken = localStorage.getItem(AUTH0_JWT)
  const refreshToken = localStorage.getItem(AUTH0_REFRESH)

  const params = {
    param: {
      externalToken,
      refreshToken
    }
  }

  const url = API_URL + '/v3/authorizations'
  const config = {
    method: 'POST',
    withCredentials: true,
    body: params
  }

  function success(data) {
    return get(data, 'result.content.token')
  }

  return fetchJSON(url, config).then(success)
}

function setTcJwt(token) {
  localStorage.setItem(TC_JWT, token)
}

function setSSOToken() {
  localStorage.setItem(V2_SSO, readCookie(V2_COOKIE) || '' )
}

// refreshPromise is needed outside the function scope to allow multiple calls
// to chain off an existing promise
export function refreshToken() {
  const token = localStorage.getItem(TC_JWT)
  const url = API_URL + '/v3/authorizations/1'
  const config = {
    headers: {
      Authorization: 'Bearer ' + token
    }
  }

  return fetchJSON(url, config)
    .then( data => {
      // Assign it to local storage
      const newToken = get(data, 'result.content.token')
      localStorage.setItem(TC_JWT, newToken)

      return newToken
    })
}

export function login(options) {
  return auth0Signin(options)
    .then(setAuth0Tokens)
    .then(getNewJWT)
    .then(setTcJwt)
    .then(setSSOToken)
}

export function sendResetEmail(email) {
  return fetchJSON(API_URL + '/v3/users/resetToken?email=' + email + '&source=connect')
}

export function resetPassword(handle, resetToken, password) {
  const url = API_URL + '/v3/users/resetPassword'
  const config = {
    method: 'PUT',
    body: {
      param: {
        handle,
        credential: {
          password,
          resetToken
        }
      }
    }
  }

  return fetchJSON(url, config)
}

export function registerUser({param, options}) {
  const url = API_URL + '/v3/users'
  const config = {
    method: 'POST',
    body: {
      param,
      options
    }
  }

  return fetchJSON(url, config)
}

export function generateSSOUrl(org, callbackUrl) {
  const apiUrl = replace(API_URL, 'api-work', 'api')

  return [
    'https://' + AUTH0_DOMAIN + '/authorize?',
    'response_type=token',
    '&client_id=' + AUTH0_CLIENT_ID,
    '&connection=' + org,
    '&redirect_uri=' + apiUrl + '/pub/callback.html',
    '&state=' + (encodeURIComponent(callbackUrl)),
    '&scope=openid%20profile%20offline_access',
    '&device=device'
  ].join('')
}

export function getSSOProvider(handle) {
  const filter = encodeURIComponent('handle=' + handle)

  function success(res) {
    const content = get(res, 'data.result.content')

    if (!content) {
      throw new AuthException({
        message: 'Could not contact login server',
        reason: 'Body did not contain content',
        response: res
      })
    }

    if (content.type !== 'samlp') {
      throw new AuthException({
        message: 'This handle does not appear to have an SSO login associated',
        reason: 'No provider of type \'samlp\'',
        response: res
      })
    }

    return content.name
  }

  function failure(res) {
    throw new AuthException({
      message: get(res, 'data.result.content') || 'Could not contact login server'
    })
  }

  return fetchJSON(API_URL + '/v3/identityproviders?filter=' + filter)
    .catch(failure)
    .then(success)
}