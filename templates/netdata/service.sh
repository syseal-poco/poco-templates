#!/bin/bash
######################################################################################
###############################  FUNCTION  ###########################################
######################################################################################
function host_setup {

  if [[ "${COMMAND}" == "install" ]]; then
    mkdir -vp "${HOME}"/containers/netdataconfig
    mkdir -vp "${HOME}"/containers/netdatalib
    mkdir -vp "${HOME}"/containers/netdatacache
  fi

}

function service_set {

  podman create --hostname "${CFG_NAME}" --name "${CFG_NAME}" \
    -p "${CFG_IP}":"${CFG_PORT}":19999 \
    --group-add keep-groups \
    --cap-add SYS_PTRACE \
    --security-opt apparmor=unconfined \
    --label "io.containers.autoupdate=registry" \
    -v "${HOME}"/containers/netdataconfig:/etc/netdata \
    -v "${HOME}"/containers/netdatalib:/var/lib/netdata \
    -v "${HOME}"/containers/netdatacache:/var/cache/netdata \
    -v /etc/passwd:/host/etc/passwd:ro \
    -v /etc/group:/host/etc/group:ro \
    -v /proc:/host/proc:ro \
    -v /sys:/host/sys:ro \
    -v /etc/os-release:/host/etc/os-release:ro \
    "${CFG_IMAGE}"

}
