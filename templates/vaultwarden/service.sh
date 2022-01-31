#!/bin/bash
######################################################################################
###############################  FUNCTION  ###########################################
######################################################################################
function service_edit {

  if [[ -z "$1" ]] && [[ -z "${ADMIN_TOKEN}" ]]; then
    ADMIN_TOKEN=$(openssl rand -base64 48)
    edit_conf_files_equal ADMIN_TOKEN "${ADMIN_TOKEN}" configs/app.env
  fi

}

function host_setup {

  if [[ "${COMMAND}" == "install" ]]; then
    mkdir -vp "${HOME}"/containers/vw-data
  fi

}

function service_set {

  podman create --hostname "${CFG_NAME}" --name "${CFG_NAME}" \
    -p "${CFG_IP}":"${CFG_PORT}":80 \
    --label "io.containers.autoupdate=registry" \
    --env-file "${HOME}/configs/app.env" \
    -v "${HOME}"/containers/vw-data:/data \
    "${CFG_IMAGE}"

}
