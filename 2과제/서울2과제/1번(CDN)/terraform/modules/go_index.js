async function handler(event) {
  const request = event.request;
  const headers = request.headers;
  const host = request.headers.host.value;
  const uri = request.uri;
  const newurl = `https://${host}/index.html`;
  
  if (!uri.startsWith('/index.html')) {
      const response = {
        statusCode: 302,
        statusDescription: 'Found',
        headers:
          { "location": { "value": newurl } }
      }
      return response;
  }

  return request;
}