#!/bin/bash
# EC2 User Data Script for apt-devops-api deployment

set -e

# --- 1. Install Dependencies ---
echo "Updating system and installing dependencies..."
# Update package list and install Node.js, systemd tools
yum update -y
# Install Node.js v18
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs
yum install -y systemd

# --- 2. Configure Node.js Application ---
echo "Creating application directory and server.js file..."
APP_DIR="/opt/app"
mkdir -p $APP_DIR
cd $APP_DIR

# The actual content of the Node.js server.js
cat << 'EOF' > server.js
const http = require('http');
const port = 8080; // App must run on port 8080 

const server = http.createServer((req, res) => {
  // Log request to stdout/CloudWatch 
  console.log(`[${new Date().toISOString()}] Request received: ${req.method} ${req.url}`);

  if (req.url === '/health') {
    // /health endpoint returns 'ok' 
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('ok');
  } else if (req.url === '/') {
    // Root endpoint returns simple text 
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Welcome to the Apt DevOps API! Instance ID: ' + process.env.HOSTNAME);
  } else {
    res.statusCode = 404;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Not Found');
  }
});

server.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});
EOF

# --- 3. Configure Systemd Service ---
echo "Creating systemd service file..."
SYSTEMD_CONFIG="/etc/systemd/system/apt-api.service"
cat << EOF > $SYSTEMD_CONFIG
[Unit]
Description=Apt DevOps Node.js API Service
After=network.target

[Service]
Environment=HOSTNAME=%H
User=ec2-user
WorkingDirectory=$APP_DIR
ExecStart=/usr/bin/node server.js
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Reload and Start Service
echo "Enabling and starting the service..."
systemctl daemon-reload
systemctl enable apt-api.service
systemctl start apt-api.service

echo "Configuration complete."
