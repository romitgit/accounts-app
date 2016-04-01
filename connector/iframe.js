const iframe = document.createElement('iframe')

iframe.src = 'http://local.accounts.topcoder-dev.com:8000/connector.html'

document.body.appendChild(iframe)

export default iframe