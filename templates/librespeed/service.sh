#!/bin/bash
######################################################################################
###############################  FUNCTION  ###########################################
######################################################################################
function service_edit {

  if [[ "$1" == "app.env" ]]; then
    FILE_APP="${HOME}/configs/app.env"
    ask_password_helper "human" PASSWORD "${FILE_APP}"
  fi

}

function host_setup {

  if [[ "${COMMAND}" == "install" ]]; then
    mkdir -vp "${HOME}"/containers/data
  fi

}

function service_set {

  podman create --hostname "${CFG_NAME}" --name "${CFG_NAME}" \
    -p "${CFG_IP}":"${CFG_PORT}":80 \
    --label "io.containers.autoupdate=registry" \
    --env-file "${HOME}/configs/app.env" \
    -v "${HOME}"/containers/data:/config \
    "${CFG_IMAGE}"
}
