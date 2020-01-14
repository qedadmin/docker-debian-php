#!/usr/bin/with-contenv bash

for VERSION in '5.6' '7.2' '7.4'; do
  if ls /etc/php/${VERSION}/fpm/pool.d/*.conf &>/dev/null; then
    echo "Enabling php${VERSION}-fpm service"
    mkdir -p /etc/services.d/php${VERSION}-fpm/
    cat <<EOT > /etc/services.d/php${VERSION}-fpm/run
#!/usr/bin/env bash
exec /usr/sbin/php-fpm${VERSION} --allow-to-run-as-root -c /etc/php/${VERSION}/fpm --nodaemonize
EOT
  chmod +x /etc/services.d/php${VERSION}-fpm/run
  else
    echo "Skipped php${VERSION}-fpm service"
  fi
done


