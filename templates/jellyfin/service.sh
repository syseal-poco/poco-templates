#!/bin/bash
######################################################################################
###############################  FUNCTION  ###########################################
######################################################################################
function service_edit {

  if [[ "$1" == "service.env" ]]; then
    ask_path_helper "folder" PATH_MEDIA "${SERVICE_ENV}"
    #chown "${SERVICE}":"${CFG_GROUP}" "${PATH_MEDIA}"
  fi

}

function host_setup {

  if [[ "${COMMAND}" == "install" ]]; then
    mkdir -vp "${HOME}"/containers/jellyfin/{config,cache}
  fi
  #Add jellyfin to video and render group to access hardware
  if [[ "${COMMAND}" == "install" ]] || [[ "${COMMAND}" == "restore" ]]; then
    usermod -a -G "video" "${SERVICE}"
    usermod -a -G "render" "${SERVICE}"
    #TODO: install amd driver if ...
    #TODO: install if not intel-media-va-driver-non-free // intel-media-va-driver for intel
  fi

  #HACK: change permission to dri device. podman got issue (https://www.redhat.com/sysadmin/files-devices-podman)
  #Podman users are running into a problem accessing files and devices within a container, even when the users have access to those resources on the host
  find /dev/dri -type c -print0 | xargs -0 chmod -v o+rw

}

#boot, shutdown, hibernate, suspend
function host_event {

  #Change permissions for gpu card(s)
  if [[ "$1" == "boot" ]]; then
    find /dev/dri -type c -print0 | xargs -0 chmod -v o+rw
  fi
}

function service_set {

  podman create --hostname "${CFG_NAME}" --name "${CFG_NAME}" \
    --group-add keep-groups \
    -p "${CFG_IP}":"${CFG_PORT}":8096 \
    -p 1900:1900/udp \
    -p 7359:7359/udp \
    -e JELLYFIN_PublishedServerUrl=https://"${CFG_HOST}" \
    --label "io.containers.autoupdate=registry" \
    --device /dev/dri:/dev/dri \
    -v "${HOME}"/containers/jellyfin/config:/config \
    -v "${HOME}"/containers/jellyfin/cache:/cache \
    -v "${PATH_MEDIA}":/mnt:ro,z \
    "${CFG_IMAGE}"

}
