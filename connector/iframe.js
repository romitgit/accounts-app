import { CONNECTOR_URL } from '../core/constants.js'

const iframe = document.createElement('iframe')

iframe.src = CONNECTOR_URL

document.body.appendChild(iframe)

export default iframe