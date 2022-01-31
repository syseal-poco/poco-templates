#!/bin/bash
######################################################################################
###############################  FUNCTION  ###########################################
######################################################################################

function host_setup {

  if [[ "${COMMAND}" == "install" ]]; then
    mkdir -vp "${HOME}"/containers/dashy/
    touch "${HOME}"/containers/dashy/config.yml
  fi

}

function service_set {

  podman create --hostname "${CFG_NAME}" --name "${CFG_NAME}" \
    -p "${CFG_IP}":"${CFG_PORT}":80 \
    --label "io.containers.autoupdate=registry" \
    -v "${HOME}"/containers/dashy/config.yml:/app/public/conf.yml \
    "${CFG_IMAGE}"

}
