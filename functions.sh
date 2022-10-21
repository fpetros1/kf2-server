#!/bin/sh

KF2_SERVER_ROOT="/kf2-server"
KF_EXEC_PATH="${KF2_SERVER_ROOT}/Binaries/Win64/KFGameSteamServer.bin.x86_64"
KF_WEB_PATH="${KF2_SERVER_ROOT}/KFGame/Config/KFWeb.ini"
START_SERVER_EXEC_PATH="${KF2_SERVER_ROOT}/start_server"
TIMEOUT_LENGTH=20

function install_or_update_kf2_server() {

    steamcmd +force_install_dir "${KF2_SERVER_ROOT}" +login anonymous +app_update 232130 +exit

}

function prepare_server_executable() {

   if [ -z "${KF_MAP}" ]; then
       KF_MAP=KF-BurningParis
   fi

   SERVER_STRING="${KF_MAP}"

   # Parameters
   if [ ! -z "${KF_ADMIN}" ]; then
      SERVER_STRING+="?AdminName=${KF_ADMIN}"
   fi

   if [ ! -z "${KF_ADMIN_PASSWORD}" ]; then
      SERVER_STRING+="?AdminPassword=${KF_ADMIN_PASSWORD}"
   fi

   if [ ! -z "${KF_MAX_PLAYERS}" ]; then
      SERVER_STRING+="?MaxPlayers=${KF_MAX_PLAYERS}"
   fi

   if [ ! -z "${KF_DIFFICULTY}" ]; then
      SERVER_STRING+="?Difficulty=${KF_DIFFICULTY}"
   fi

   if [ ! -z "${KF_GAME_PASSWORD}" ]; then
      SERVER_STRING+="?GamePassword=${KF_GAME_PASSWORD}"
   fi

   # Switches
   if [ ! -z "${KF_PORT}" ]; then
      SERVER_STRING+=" -Port=${KF_PORT}"
   fi

   if [ ! -z "${KF_QUERY_PORT}" ]; then
      SERVER_STRING+=" -QueryPort=${KF_QUERY_PORT}"
   fi

   if [ ! -z "${KF_WEBADMIN_PORT}" ]; then
      SERVER_STRING+=" -WebAdminPort=${KF_WEBADMIN_PORT}"
   fi

   if [ ! -z "${KF_MULTIHOME}" ]; then
      SERVER_STRING+=" -Multihome=${KF_MULTIHOME}"
   fi

   if [ ! -z "${KF_PREFERRED_PROCESSOR}" ]; then
      SERVER_STRING+=" -PREFERREDPROCESSOR=${KF_PREFERRED_PROCESSOR}"
   fi

   if [ ! -z "${KF_CONFIG_SUB_DIR}" ]; then
      SERVER_STRING+=" -ConfigSubDir=${KF_PREFERRED_PROCESSOR}"
   fi

   echo "${KF_EXEC_PATH} ${SERVER_STRING}" > "${START_SERVER_EXEC_PATH}"
   chmod +x "${START_SERVER_EXEC_PATH}"

}

function ensure_create_configs() {
   if [[ ! -f "${KF_WEB_PATH}" ]]; then
     echo "Running server to create config files..."
     timeout -k $TIMEOUT_LENGTH $TIMEOUT_LENGTH "${START_SERVER_EXEC_PATH}" > /dev/null 2>&1
     echo "Killing server, config files created"
   fi
}

function apply_configs() {
   if [ ! -z "${KF_WEBADMIN}" ]; then
      sed -i "s/^bEnabled=.*/bEnabled=${KF_WEBADMIN}\r/" "${KF_WEB_PATH}"
   fi
}

function start_server() {
   "${START_SERVER_EXEC_PATH}"
}
