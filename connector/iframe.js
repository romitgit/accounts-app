const iframe = document.createElement('iframe')

iframe.src = 'http://localhost:8000/connector.html'

document.body.appendChild(iframe)

export default iframe