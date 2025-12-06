// app/server.js content (minimal REST API)
const http = require('http');
const port = 8080;

const server = http.createServer((req, res) => {
  // Logs should print to stdout [cite: 31]
  console.log(`[${new Date().toISOString()}] Request received: ${req.method} ${req.url}`);

  if (req.url === '/health') {
    // /health -> returns ok 
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('ok');
  } else if (req.url === '/') {
    // / -> returns a simple text response [cite: 45]
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end(`Welcome to the Apt DevOps API! Running on host: ${process.env.HOSTNAME || 'Unknown'}`);
  } else {
    res.statusCode = 404;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Not Found');
  }
});

server.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});