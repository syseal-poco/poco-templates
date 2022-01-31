#!/bin/bash
######################################################################################
###############################  FUNCTION  ###########################################
######################################################################################
function host_setup {

  if [[ "${COMMAND}" == "install" ]]; then
    mkdir -vp "${HOME}"/containers/config
  fi
}

function service_set {

  podman create --hostname "${CFG_NAME}" --name "${CFG_NAME}" \
    -p "${CFG_IP}":"${CFG_PORT}":80 \
    --label "io.containers.autoupdate=registry" \
    -e fpm="false" \
    -e branch="v2-master" \
    -v "${HOME}"/containers/config:/config \
    "${CFG_IMAGE}"

}
