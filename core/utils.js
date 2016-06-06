import pickBy from 'lodash/pickBy'
import mapValues from 'lodash/mapValues'
import fromPairs from 'lodash/fromPairs'

export function getLoginConnection(userId) {
  return isEmail(userId) ? 'TC-User-Database' : 'LDAP'
}

export function isEmail(value) {
  const EMAIL_PATTERN = /^(([^<>()[\]\.,:\s@\"]+(\.[^<>()[\]\.,:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,:\s@\"]+\.)+[^<>()[\]\.,:\s@\"]{2,})$/i

  return EMAIL_PATTERN.test(value)
}

export function encodeParams(params, includeNull) {
  const relevantParams = pickBy(params, v => v || includeNull )

  return mapValues(relevantParams, v => encodeURIComponent(v) )
}

export function parseQuery(query) {
  const params = query.split('&').map( param => {
    const [ k, v ] = param.split('=')

    return [ k, v ? decodeURIComponent(v) : null ]
  })

  return fromPairs(params)
}

export function setupLoginEventMetrics(id) {
  if (window._kmq) {
    return window._kmq.push(['identify', id])
  }
}

export function npad(input, n) {
  if(input === undefined) input = ''
  var inputStr = input
  if (typeof input !== 'string') {
    inputStr = input.toString()
  }
  if(inputStr.length >= n)
    return inputStr
  var zeros = new Array( n + 1 ).join('0')
  return (zeros + inputStr).slice(-1 * n)
}

export function supplant(template, values, pattern) {
  pattern = pattern || /\{([^\{\}]*)\}/g

  return template.replace(pattern, function(a, b) {
    var p = b.split('.'),
      r = values

    try {
      for (var s in p) {
        r = r[p[s]]
      }
    } catch (e) {
      r = a
    }

    return (typeof r === 'string' || typeof r === 'number') ? r : a
  })
}
