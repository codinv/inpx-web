#!/bin/sh
set -e

if [ -n "$TZ" ] && [ -f "/usr/share/zoneinfo/$TZ" ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
fi

if [ -d "/data_init" ] && [ -n "$(ls -A /data_init 2>/dev/null)" ]; then
    cp -a /data_init/. /data/
    rm -rf /data_init
fi

exec /data/app-inpx-web/inpx-web \
  --app-dir=/data \
  --lib-dir="${LIB_DIR}" \
  --inpx="${INPX_FILE}"