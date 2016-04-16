import { CONNECTOR_URL } from '../core/constants.js'

const iframe = document.createElement('iframe')

iframe.id = 'TC-CONNECTOR-FRAME'

iframe.src = CONNECTOR_URL

iframe.width = 0

iframe.height = 0

iframe.frameborder = 0

document.body.appendChild(iframe)

export default iframe