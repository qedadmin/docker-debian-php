#!/usr/bin/with-contenv bash

echo "Enabling Post-Service"
mkdir -p /etc/services.d/post-service/
cat <<EOT > /etc/services.d/post-service/run
#!/usr/bin/env bash
SUPERVISED_DIR=/var/run/s6/services/

if ls -ald /etc/services.d/* &>/dev/null; then
  for service in /etc/services.d/*; do
    svc=$(basename "${service}")
    if [ "${svc}" != "post-service" ]; then
      echo "[post-service] ensure ${svc} is ready"
      s6-svwait -u "${SUPERVISED_DIR}/${svc}"
    fi
  done
  echo "[post-service] all services up"
fi
RUN_SCRIPTS=/etc/run1.d
STATUS=0
# Run shell scripts (ending in .sh) in run.d directory

if ls ${RUN_SCRIPTS}/*.sh &>/dev/null; then
  for file in $RUN_SCRIPTS/*.sh; do

    echo "[init] executing ${file}"

    /bin/bash -e $file

    STATUS=$?

    if [[ $STATUS == $SIGNAL_BUILD_STOP ]]; then
      echo "[init] exit signalled - ${file}"
      exit $STATUS
    fi

    if [[ $STATUS != 0 ]]; then
      echo "[init] failed executing - ${file}"
      exit $STATUS
    fi

  done
else
  echo "[init] no run1.d scripts"
fi
s6-svc -x ${SUPERVISED_DIR}/post-service
rm -rf ${SUPERVISED_DIR}/post-service
s6-svscanctl -a ${SUPERVISED_DIR}
echo "[post-service] complete"
EOT
chmod +x /etc/services.d/post-service/run
