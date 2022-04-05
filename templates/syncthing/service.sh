#!/bin/bash
######################################################################################
###############################  FUNCTION  ###########################################
######################################################################################

function service_edit {

  if [[ "$1" == "service.env" ]]; then
    #Torrent Path control
    ask_path_helper "folder" CFG_PATH_DATA "${SERVICE_ENV}"
  fi

}

function host_setup {

  #Create container storage
  if [[ "${COMMAND}" == "install" ]]; then
    mkdir -vp "${HOME}"/containers/config
  fi
}

function service_set {

  podman create --hostname "${CFG_NAME}" --name "${CFG_NAME}" \
    -p "${CFG_IP}":"${CFG_PORT}":8384 -p "${CFG_PORT_APP_TCP}":22000/tcp -p "${CFG_PORT_APP_UDP}":22000/udp \
    -e PUID=1000 \
    -e PGID=1000 \
    --user=1000:1000 \
    --group-add keep-groups \
    --label "io.containers.autoupdate=registry" \
    -v "${HOME}"/containers/config:/var/syncthing/config \
    -v "${CFG_PATH_DATA}":/mnt/syncthing \
    "${CFG_IMAGE}"

  podman unshare chown 1000:1000 "${HOME}"/containers/config

}

function service_exec {

  return 0

}
