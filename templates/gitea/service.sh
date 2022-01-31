#!/bin/bash
######################################################################################
###############################  FUNCTION  ###########################################
######################################################################################

function service_edit {

  FILE_APP="${HOME}/configs/app.env"
  FILE_DB="${HOME}/configs/db.env"

  if [[ -z "$1" ]]; then
    if [[ -z "${GITEA__database__PASSWD}" ]]; then
      edit_conf_files_equal "GITEA__database__PASSWD" "${MYSQL_PASSWORD}" "${FILE_APP}"
    fi
    #Edit app.ini
    local config="${HOME}/containers/gitea/data/gitea/conf/app.ini"
    if [[ -f "${config}" ]]; then
      ${CFG_EDITOR:?} "${config}"
    fi
  elif [[ "$1" == "service.env" ]]; then
    ask_password_helper "human" CFG_ADMIN_PWD "${SERVICE_ENV}"
    ask_email_helper CFG_ADMIN_EMAIL "${SERVICE_ENV}"
  elif [[ "$1" == "db.env" ]]; then
    ask_password_helper "human" MYSQL_ROOT_PASSWORD "${FILE_DB}"
    ask_password_helper "human" MYSQL_PASSWORD "${FILE_DB}"
  fi

}

function host_setup {
  if [[ "${COMMAND}" == "install" ]]; then
    mkdir -vp "${HOME}"/containers/gitea/{db,data}
  fi
}

function service_set {

  #Create pod
  podman pod create --hostname "${CFG_NAME}" --name "${CFG_NAME}" -p "${CFG_IP}":"${CFG_PORT}":3000 -p "${CFG_PORT_SSH}":"${GITEA__server__SSH_LISTEN_PORT}"

  podman create --pod="${CFG_NAME}" --name="${CFG_NAME}"-db \
    --label "io.containers.autoupdate=registry" \
    --env-file "${HOME}/configs/db.env" \
    -v "${HOME}"/containers/gitea/db:/var/lib/mysql \
    "${CFG_IMAGE_DB}" \
    --transaction-isolation=READ-COMMITTED --binlog-format=ROW

  podman create --pod="${CFG_NAME}" --name="${CFG_NAME}"-app \
    --label "io.containers.autoupdate=registry" \
    --env-file "${HOME}/configs/app.env" \
    -v "${HOME}"/containers/gitea/data:/data \
    "${CFG_IMAGE_APP}"

}

function service_exec {

  if [[ "${COMMAND}" == "install" ]]; then
    until podman container exists "${CFG_NAME}"-app; do
      echo "Container not running, retrying in 10 seconds..."
      sleep 10
    done
    echo "Wait 20 seconds the container to be up..."
    sleep 20
    until podman exec -it "${CFG_NAME}"-app gitea admin user create --username="${CFG_ADMIN_NAME}" --password="${CFG_ADMIN_PWD}" --email="${CFG_ADMIN_EMAIL}"; do
      echo "Command fail, container not up yet"
      sleep 5
    done
  fi
}
