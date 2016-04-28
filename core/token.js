import { V3_JWT, AUTH0_REFRESH, AUTH0_JWT, V2_JWT, V2_SSO, ZENDESK_JWT } from './constants.js'
import map from 'lodash/map'
import fromPairs from 'lodash/fromPairs'

export function clearTokens() {
  removeToken(V3_JWT)
  removeToken(AUTH0_REFRESH)
  removeToken(AUTH0_JWT)
  removeToken(ZENDESK_JWT)
  deleteCookie(V2_JWT)
  deleteCookie(V2_SSO)
}

window.clearTokens = clearTokens

export function getToken(key) {
  return readCookie(key)
}

export function setToken(key, token) {
  updateCookie(key, token)
}

export function removeToken(key) {
  deleteCookie(key)
}

export function decodeToken(token) {
  const parts = token.split('.')

  if (parts.length !== 3) {
    throw new Error('JWT must have 3 parts')
  }

  const decoded = urlBase64Decode(parts[1])

  if (!decoded) {
    throw new Error('Cannot decode the token')
  }

  return JSON.parse(decoded)
}

export function isTokenExpired(token, offsetSeconds = 0) {
  const d = getTokenExpirationDate(token)

  if (d === null) {
    return false
  }

  // Token expired?
  return !(d.valueOf() > (new Date().valueOf() + (offsetSeconds * 1000)))
}

function urlBase64Decode(str) {
  let output = str.replace(/-/g, '+').replace(/_/g, '/')

  switch (output.length % 4) {
    case 0:
      break 

    case 2:
      output += '=='
      break

    case 3:
      output += '='
      break

    default:
      throw 'Illegal base64url string!'
  }
  return decodeURIComponent(escape(atob(output))) //polyfill https://github.com/davidchambers/Base64.js
}

function getTokenExpirationDate(token) {
  const decoded = decodeToken(token)

  if(typeof decoded.exp === 'undefined') {
    return null
  }

  const d = new Date(0) // The 0 here is the key, which sets the date to the epoch
  d.setUTCSeconds(decoded.exp)

  return d
}

function parseCookie(cookie) {
  return fromPairs( cookie.split(';').map( (pair) => pair.split('=').map( (part) => part.trim() ) ) )
}

export function readCookie(name) {
  return parseCookie( document.cookie )[name]
}

export function updateCookie(name, value, days) {
  let expires = ''

  if (days) {
    const date = new Date()
    date.setTime( date.getTime() + (days * 24 * 60 * 60 * 1000) )
    expires = '; expires=' + date.toGMTString()
  }  else {
    expires = ''
  }

  document.cookie = name + '=' + value + expires + '; path=/'
}

function deleteCookie(name) {
	updateCookie(name,"",-1);
}