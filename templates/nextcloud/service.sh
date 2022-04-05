#!/bin/bash
######################################################################################
###############################  FUNCTION  ###########################################
######################################################################################
function service_edit {

  FILE_NEXTCLOUD_ENV="${HOME}/configs/app.env"
  FILE_MARIADB_ENV="${HOME}/configs/db.env"

  #If empty, all edition was done
  if [[ -z "$1" ]]; then
    ask_password_helper "human" MYSQL_ROOT_PASSWORD "${FILE_MARIADB_ENV}"
    ask_password_helper "human" MYSQL_PASSWORD "${FILE_MARIADB_ENV}" "${FILE_NEXTCLOUD_ENV}"
    ask_password_helper "human" NEXTCLOUD_ADMIN_PASSWORD "${FILE_NEXTCLOUD_ENV}"
    #Edit config.php
    local config="${HOME}/containers/nextcloud/html/config/config.php"
    if [[ -f "${config}" ]]; then
      #use podman unshare to edit this file (permissions) (only on rootless mode)
      #podman unshare nano -Il "${config}"
      ${CFG_EDITOR:?} "${config}"
    fi
  elif [[ "$1" == "service.env" ]]; then
    ask_path_helper "folder" CFG_PATH_DATA "${SERVICE_ENV}"
    ask_path_helper "folder" CFG_PATH_USER "${SERVICE_ENV}"
  fi

}

function host_setup {

  #Create container storage
  if [[ "${COMMAND}" == "install" ]]; then
    mkdir -vp "${HOME}"/containers/nextcloud/{db,html}
  fi
  if [[ "${COMMAND}" == "install" ]] || [[ "${COMMAND}" == "restore" ]]; then
    chown -v root:"${CFG_GROUP}" "${CFG_PATH_USER}"
    #Set Permission for nextcloud folders
    chown -vR "${SERVICE}":"${SERVICE}" "${CFG_PATH_DATA:?}"
  fi

}

function service_set {

  #Create pod
  podman pod create --hostname "${CFG_NAME}" --name "${CFG_NAME}" -p "${CFG_IP}":"${CFG_PORT}":80

  podman create --pod="${CFG_NAME}" --name="${CFG_NAME}"-db \
    --label "io.containers.autoupdate=registry" \
    --env-file "${HOME}/configs/db.env" \
    -v "${HOME}"/containers/nextcloud/db:/var/lib/mysql \
    "${CFG_IMAGE_DB}" \
    --transaction-isolation=READ-COMMITTED --binlog-format=ROW

  podman create --pod="${CFG_NAME}" --name="${CFG_NAME}"-app \
    --group-add keep-groups \
    --label "io.containers.autoupdate=registry" \
    --env-file "${HOME}/configs/app.env" \
    -v "${CFG_PATH_DATA}":/var/www/html/data \
    -v "${CFG_PATH_USER}":/mnt/users:z \
    -v "${HOME}"/containers/nextcloud/html:/var/www/html \
    "${CFG_IMAGE_NC}"

}

function service_exec {

  #podman unshare nano -Il "${nc_config}"
  #When restore. We need change CFG_PATH_DATA UID:GID to match with the current containers
  # until podman container exists "${CFG_NAME}"-app; do
  #     echo "Container not running, retrying in 10 seconds..."
  #     sleep 10
  # done
  #Make sure the containers got good permission on data folder.
  # until podman exec nextcloud-app chown -R www-data:www-data /var/www/html/data; do
  #     echo "Command fail, container not up yet"
  #     sleep 5
  # done
  if [[ "${COMMAND}" == "install" ]] || [[ "${COMMAND}" == "restore" ]]; then
    #Data Permissions update
    podman unshare chown -R www-data:www-data "${CFG_PATH_DATA}"
    podman unshare find "${CFG_PATH_DATA}" -type d -exec chmod 750 {} \;
    podman unshare find "${CFG_PATH_DATA}" -type f -exec chmod 640 {} \;

    #Mounted volume user update
    podman unshare chown -R www-data "${CFG_PATH_USER}"
    podman unshare find "${CFG_PATH_USER}" -type d -exec chmod 2770 {} \;
    podman unshare find "${CFG_PATH_USER}" -type f -exec chmod 0660 {} \;
  fi
}
