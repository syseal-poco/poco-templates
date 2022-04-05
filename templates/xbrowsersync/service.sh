#!/bin/bash
######################################################################################
###############################  FUNCTION  ###########################################
######################################################################################
function service_edit {


}

function host_setup {

}

#boot, shutdown, hibernate, suspend
function host_event {

  return 0
}

function service_set {

  #Create pod
  podman pod create --hostname "${CFG_NAME}" --name "${CFG_NAME}" -p "${CFG_IP}":"${CFG_PORT}":80

  podman create --pod="${CFG_NAME}" --name="${CFG_NAME}"-db \
    --label "io.containers.autoupdate=registry" \
    --env-file "${HOME}/configs/db.env" \
    -e XBS_DB_NAME=${MONGO_INITDB_DATABASE} \
    -e XBS_DB_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD} \
    -e XBS_DB_USERNAME=${MONGO_INITDB_ROOT_USERNAME} \
    -v "${HOME}"/containers/db/data:/data/db \
    -v "${HOME}"/containers/db/backups:/data/backups \
    "${CFG_IMAGE_DB}"

  podman create --pod="${CFG_NAME}" --name="${CFG_NAME}"-app \
    --label "io.containers.autoupdate=registry" \
    -e XBROWSERSYNC_DB_PWD=${MONGO_INITDB_ROOT_PASSWORD} \
    -e XBROWSERSYNC_DB_USER=${MONGO_INITDB_ROOT_USERNAME} \
    -v "${HOME}"/configs/settings.json:/usr/src/api/config/settings.json \
    -v "${HOME}"/configs/healthcheck.js:/usr/src/api/healthcheck.js \
    --health-cmd [ "CMD", "node", "/usr/src/api/healthcheck.js" ] \
    --health-interval 1m \
    --health-retries 5 \
    --health-start-period 30s \
    --health-timeout 10s \
    "${CFG_IMAGE_APP}"

}

