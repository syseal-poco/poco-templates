#!/bin/bash
######################################################################################
###############################  FUNCTION  ###########################################
######################################################################################
function service_edit {

  FILE_APP="${HOME}/configs/app.env"
  FILE_DB="${HOME}/configs/db.env"
  FILE_RUNNER="${HOME}/configs/runner.env"

  if [[ "$1" == "app.env" ]]; then
    ask_password_helper "secret" DRONE_RPC_SECRET "${FILE_APP}" "${FILE_RUNNER}"
    ask_password_helper "secret" DRONE_GITEA_CLIENT_ID "${FILE_APP}"
    ask_password_helper "secret" DRONE_GITEA_CLIENT_SECRET "${FILE_APP}"
    if [[ -z "${DRONE_DATABASE_DATASOURCE}" ]]; then
      db_connection="drone:${MYSQL_PASSWORD}@tcp(localhost:3306)/drone?parseTime=true"
      edit_conf_files_equal "DRONE_DATABASE_DATASOURCE" "${db_connection}" "${FILE_APP}"
    fi
  elif [[ "$1" == "db.env" ]]; then
    ask_password_helper "human" MYSQL_ROOT_PASSWORD "${FILE_DB}"
    ask_password_helper "human" MYSQL_PASSWORD "${FILE_DB}"
  fi

}

function host_setup {

  if [[ "${COMMAND}" == "install" ]]; then
    mkdir -vp "${HOME}"/containers/drone/{db,data}
  fi

}

function service_set {

  #Create pod
  podman pod create --hostname "${CFG_NAME}" --name "${CFG_NAME}" -p "${CFG_IP}":"${CFG_PORT}":80

  podman create --pod="${CFG_NAME}" --name="${CFG_NAME}"-db \
    --label "io.containers.autoupdate=registry" \
    --env-file "${HOME}/configs/db.env" \
    -v "${HOME}"/containers/drone/db:/var/lib/mysql \
    "${CFG_IMAGE_DB}" \
    --transaction-isolation=READ-COMMITTED --binlog-format=ROW

  podman create --pod="${CFG_NAME}" --name="${CFG_NAME}"-app \
    --label "io.containers.autoupdate=registry" \
    --env-file "${HOME}/configs/app.env" \
    -v "${HOME}"/containers/drone/data:/data \
    "${CFG_IMAGE_APP}"

  # podman create --pod="${CFG_NAME}" --name="${CFG_NAME}"-app \
  #     --label "io.containers.autoupdate=registry" \
  #     --env-file "${HOME}/configs/runner.env" \
  #     "${CFG_REGISTRY}"/"${CFG_IMAGE_RUNNER}"

}
