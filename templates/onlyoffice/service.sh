#!/bin/bash
######################################################################################
###############################  FUNCTION  ###########################################
######################################################################################
function service_edit {

  #Check if password was set and ask to generate them
  if [[ "$1" == "app.env" ]]; then
    if [[ -z ${JWT_SECRET} ]]; then
      ask_password_helper "secret" JWT_SECRET "${HOME}"/configs/app.env
    fi
  fi

}

function host_setup {

  if [[ "${COMMAND}" == "install" ]]; then
    mkdir -vp "${HOME}"/containers/DocumentServer/{logs,data}
  fi

}

function service_set {

  podman create --restart=no --hostname "${CFG_NAME}" --name "${CFG_NAME}" \
    -p "${CFG_IP}":"${CFG_PORT}":80 \
    --label "io.containers.autoupdate=registry" \
    --env-file "${HOME}/configs/app.env" \
    -v "${HOME}"/containers/DocumentServer/logs:/var/log/onlyoffice \
    -v "${HOME}"/containers/DocumentServer/data:/var/www/onlyoffice/Data \
    "${CFG_IMAGE}"

}
