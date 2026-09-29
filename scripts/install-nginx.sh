#!/bin/bash

set -e

apt-get update
apt-get install -y nginx

HOSTNAME=$(hostname)

cat > /var/www/html/index.html <<EOF
<html>
<head>
    <title>Azure E-Commerce Platform</title>
</head>
<body>
    <h1>Azure E-Commerce Platform</h1>
    <p>Web VMSS is working.</p>
    <p>Server: $HOSTNAME</p>
</body>
</html>
EOF

systemctl enable nginx
systemctl restart nginx

