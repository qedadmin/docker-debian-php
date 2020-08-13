#!/usr/bin/with-contenv bash

if [ -f /etc/haproxy/haproxy.cfg ]; then  # Make sure the file exists
	  echo "Enabling HAProxy service"
    mkdir -p /etc/services.d/haproxy/
    cat <<EOT > /etc/services.d/haproxy/run
#!/usr/bin/env bash
exec /usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg
EOT
  chmod +x /etc/services.d/haproxy/run
else
	echo "Skipped HAProxy service (Not found: /etc/haproxy/haproxy.cfg)"
fi




