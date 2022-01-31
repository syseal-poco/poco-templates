#!/bin/bash
######################################################################################
###############################  FUNCTION  ###########################################
######################################################################################
function service_edit {

  if [[ "$1" == "service.env" ]]; then
    #Check if password was set and ask to generate them
    ask_password_helper "human" CFG_ADMIN_PWD "${SERVICE_ENV}"

    #Define hash variable for substitution
    export CFG_ADMIN_PWD_HASH
    CFG_ADMIN_PWD_HASH=$(htpasswd -nbBC 10 admin "${CFG_ADMIN_PWD}")
    old_password=$(load_env_value CFG_ADMIN_PWD "${SERVICE_CACHE}/configs.bak/service.env") || :
    if [[ "${old_password}" != "${CFG_ADMIN_PWD}" ]]; then
      echo "New admin password to setup for '${SERVICE}'"
      file_subst_vars "${SERVICE_TOML}" CFG_ADMIN_PWD_HASH
      if ! grep "${CFG_ADMIN_PWD_HASH}" "${SERVICE_TOML}"; then
        traefik_change_password "admin" "${CFG_ADMIN_PWD_HASH}" "${SERVICE_TOML}"
      fi
    fi
    #Torrent Path control
    ask_path_helper "folder" CFG_PATH_TORRENT "${SERVICE_ENV}"
  fi

  #TODO: VPN Login//username management.
  #TODO: VPN Password management (without generation).
  #TODO: Ask vpn settings location

}

function host_setup {

  #Create container storage
  if [[ "${COMMAND}" == "install" ]]; then
    mkdir -vp "${HOME}"/containers/vpn/
  fi

  #Change /dev/net/tun permission
  chown -v root:"${CFG_GROUP}" /dev/net/tun

}

#boot, shutdown, hibernate, suspend
function host_event {

  #Change permissions for gpu card(s)
  if [[ "$1" == "boot" ]]; then
    chown -v root:"${CFG_GROUP}" /dev/net/tun
  fi
}

function service_set {

  podman create --hostname "${CFG_NAME}" --name "${CFG_NAME}" \
    --cap-add NET_ADMIN \
    --group-add keep-groups \
    --device /dev/net/tun:/dev/net/tun \
    -p "${CFG_IP}":"${CFG_PORT}":9091 \
    --label "io.containers.autoupdate=registry" \
    --env-file "${HOME}/configs/app.env" \
    -v "${HOME}"/containers/vpn/:/etc/openvpn/custom \
    -v "${CFG_PATH_TORRENT}":/data:z \
    "${CFG_IMAGE}"

}
