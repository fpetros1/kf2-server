#!/bin/sh

KF2_APPID=232130
KF2_SERVER_ROOT="/kf2-server/steam-server"
CACHE_PATH="${KF2_SERVER_ROOT}/KFGame/Cache"
KF_EXEC_PATH="${KF2_SERVER_ROOT}/Binaries/Win64/KFGameSteamServer.bin.x86_64"
KF_ENGINE_PATH="${KF2_SERVER_ROOT}/KFGame/Config/LinuxServer-KFEngine.ini"
KF_GAME_PATH="${KF2_SERVER_ROOT}/KFGame/Config/LinuxServer-KFGame.ini"
KF_CUSTOM_MAPS_SELECTOR="\[Custom\.Maps\]"
KF_CUSTOM_MAPS="[Custom.Maps]"
KF_WORKSHOP_HEADER_SELECTOR="\[OnlineSubsystemSteamworks\.KFWorkshopSteamworks\]"
KF_WORKSHOP_HEADER="[OnlineSubsystemSteamworks.KFWorkshopSteamworks]"
KF_WORKSHOP_ITEM_KEY="ServerSubscribedWorkshopItems"
WORKSHOP_DOWNLOAD_MANAGER="OnlineSubsystemSteamworks.SteamWorkshopDownload"
KF_WEB_PATH="${KF2_SERVER_ROOT}/KFGame/Config/KFWeb.ini"
START_SERVER_EXEC_PATH="${KF2_SERVER_ROOT}/start_server"
TIMEOUT_LENGTH=60
STEAM_UPDATED_CLIENT_LIB="/root/.steam/steamcmd/linux64/steamclient.so"
STEAM_CLIENT_LIB_PATHS="${KF2_SERVER_ROOT}/linux64/steamclient.so;${KF2_SERVER_ROOT}/steamclient.so;${KF2_SERVER_ROOT}/Binaries/Win64/lib64/steamclient.so"

function install_or_update_kf2_server() {

    steamcmd +force_install_dir "${KF2_SERVER_ROOT}" +login anonymous +app_update $KF2_APPID +exit

}

function fix_steam_libraries() {

    IFS=';' read -ra ADDR <<< "${STEAM_CLIENT_LIB_PATHS}"
    for STEAM_CLIENT_LIB in "${ADDR[@]}"; do
       if [ -f "${STEAM_CLIENT_LIB}" ]; then
         rm "${STEAM_CLIENT_LIB}"
       fi
       cp "${STEAM_UPDATED_CLIENT_LIB}" "${STEAM_CLIENT_LIB}"
    done

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

function install_mods() {
  if [ ! -z ${KF_MODS} ]; then
    mkdir -p "${CACHE_PATH}"
    REMOVED_MODS_ENGINE=$(sed "/${KF_WORKSHOP_HEADER_SELECTOR}/,\$d" "${KF_ENGINE_PATH}")
    echo "${REMOVED_MODS_ENGINE}" > "${KF_ENGINE_PATH}"

    printf "\n${KF_WORKSHOP_HEADER}\n" | tee -a "${KF_ENGINE_PATH}"

    IFS=',' read -ra ADDR <<< "${KF_MODS}"
    for MOD_ID in "${ADDR[@]}"; do
       echo "${KF_WORKSHOP_ITEM_KEY}=${MOD_ID}" | tee -a "${KF_ENGINE_PATH}"
    done

    if ! grep -q "DownloadManagers=${WORKSHOP_DOWNLOAD_MANAGER}" "${KF_ENGINE_PATH}"; then
      UPDATED_KF_ENGINE=$(sed "/^DownloadManagers=IpDrv.HTTPDownload/i DownloadManagers=${WORKSHOP_DOWNLOAD_MANAGER}\r/" "${KF_ENGINE_PATH}")
      echo "${UPDATED_KF_ENGINE}" > "${KF_ENGINE_PATH}"
    fi
  fi
}

function add_custom_maps_selector() {
    REMOVED_CUSTOM_MAPS_SEPARATOR=$(sed "/${KF_CUSTOM_MAPS_SELECTOR}/,\$d" "${KF_GAME_PATH}")
    echo "${REMOVED_CUSTOM_MAPS_SEPARATOR}" > "${KF_GAME_PATH}"

    printf "\n${KF_CUSTOM_MAPS}\n" | tee -a "${KF_GAME_PATH}"
    printf "description=Custom map entries listed below\n" | tee -a "${KF_GAME_PATH}"

    CUSTOM_MAPS=$(find "${CACHE_PATH}" -name "*.kfm" | xargs)

    IFS=' ' read -ra ADDR <<< "${CUSTOM_MAPS}"
    for CUSTOM_MAP_PATH in "${ADDR[@]}"; do
       CUSTOM_MAP_NAME=$(basename "${CUSTOM_MAP_PATH}" | cut -d "." -f 1)
       printf "\n[${CUSTOM_MAP_NAME} KFMapSummary]\n" | tee -a "${KF_GAME_PATH}"
       echo "MapName=${CUSTOM_MAP_NAME}" | tee -a "${KF_GAME_PATH}"
       echo "ScreenshotPathName=UI_MapPreview_TEX.UI_MapPreview_Placeholder" | tee -a "${KF_GAME_PATH}"
       echo "bPlayableInSurvival=True" | tee -a "${KF_GAME_PATH}"
       echo "bPlayableInWeekly=True" | tee -a "${KF_GAME_PATH}"
       echo "bPlayableInVsSurvival=True" | tee -a "${KF_GAME_PATH}"
       echo "bPlayableInEndless=True" | tee -a "${KF_GAME_PATH}"
       echo "bPlayableInObjective=True" | tee -a "${KF_GAME_PATH}"
    done
}

function apply_configs() {
   if [ ! -z "${KF_WEBADMIN}" ]; then
      sed -i "s/^bEnabled=.*/bEnabled=${KF_WEBADMIN}\r/" "${KF_WEB_PATH}"
   fi
}

function start_server() {
   "${START_SERVER_EXEC_PATH}"
}
