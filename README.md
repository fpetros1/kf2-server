# Killing Floor 2 Docker Server

- Built using Docker and SteamCMD
- [Docker Hub](https://hub.docker.com/r/fpetros/kf2-server)
- [Source Code](https://github.com/fpetros1/kf2-server)

## Basic Usage

### Docker Run
```
docker run -p 8888:8888/udp -p 27015/udp -p 8181:8181 -p 20560:20560/udp -e KF_ADMIN=Admin -e KF_ADMIN_PASSWORD=Admin -e KF_PORT=8888 -e KF_WEBADMIN_PORT=8181 -e KF_GAME_PASSWORD=123123 -e KF_WEBADMIN=True -e KF_DIFFICULTY=2 fpetros/kf2-server:latest
```

### Docker Compose
```
version: '3'

services:
  vanilla-0:
    image: fpetros/kf2-server:latest
    ports:
      - '7777:7777/udp'
      - '27015:27015/udp'
      - '8080:8080/tcp'
      - '20560:20560/tcp'
    restart: unless-stopped
    environment:
      - KF_WEBADMIN=True
      - KF_ADMIN=Admin
      - KF_ADMIN_PASSWORD=admin123123
      - KF_GAME_PASSWORD=123123
      - KF_PORT=7777
      - KF_QUERY_PORT=27015
      - KF_WEBADMIN_PORT=8080
      - KF_MODS=123123,123124,123125
    volumes:
      - kf2-server:/kf2-server/steam-server
    tty: true
    stdin_open: true
volumes:
  kf2-server:
```

## Environment Variables

## Customization
| Variable         | Description                | Possible Values               | Default       |
|------------------|----------------------------|-------------------------------|---------------|
| ```KF_MODS```    | Mod Id List(Steam Workshop), separated by ',' [How to get Workshop ID](#how-to-get-workshop-id) | 123123,123124,1231235,123456,1234567,123458 |    |

## Arguments
| Variable         | Description                | Possible Values               | Default       |
-------------------|----------------------------|-------------------------------|---------------|
| ```KF_WEBADMIN```| Enable or Disable WebAdmin | ``` True ``` or ``` False ``` | ``` False ``` |
| ```KF_MAP```     | Starting Map               | ```KF-Airship``` ```KF-AshwoodAsylum``` ```KF-BarmwichTown``` ```KF-Biolapse``` ```KF-BioticsLab``` ```KF-BlackForest``` ```KF-BurningParis``` ```KF-CarillonHamlet``` ```KF-Catacombs``` ```KF-ContainmentStation``` ```KF-Default``` ```KF-Desolation``` ```KF-DieSector``` ```KF-Dystopia2029``` ```KF-Elysium``` ```KF-EvacuationPoint``` ```KF-Farmhouse``` ```KF-HellmarkStation``` ```KF-HostileGrounds``` ```KF-InfernalRealm``` ```KF-KrampusLair``` ```KF-Lockdown``` ```KF-MonsterBall``` ```KF-Moonbase``` ```KF-Netherhold``` ```KF-Nightmare``` ```KF-Nuked``` ```KF-Outpost``` ```KF-PowerCore_Holdout``` ```KF-Prison``` ```KF-Rig``` ```KF-Sanitarium``` ```KF-SantasWorkshop``` ```KF-ShoppingSpree``` ```KF-Spillway``` ```KF-SteamFortress``` ```KF-TheDescent``` ```KF-TragicKingdom``` ```KF-VolterManor``` ```KF-ZedLanding``` | ``` KF-BurningParis ``` |
| ```KF_ADMIN```   | Username for WebAdmin      | ``` Any Alpha numeric character combinations ```||
| ```KF_ADMIN_PASSWORD```| Password for WebAdmin      | ``` Any Alpha numeric character combinations ```||
| ```KF_MAX_PLAYERS```| Maximum amount of players in the server | ``` Any integer Number ```| ``` 6 ```|
| ```KF_DIFFICULTY```| Server difficulty | ``` 0 ``` = Normal, ```1``` = Hard, ```2``` = Suicidal or ```3``` = Hell on Earth | ``` 0 ``` |

## Switches
| Variable         | Description                | Possible Values               | Default       |
|------------------|----------------------------|-------------------------------|---------------|
| ```KF_PORT```| Game Port | ``` Any integer Number ``` | ``` 7777 ``` |
| ```KF_QUERY_PORT```| Steam Query Port | ``` Any integer Number ``` | ``` 27015 ``` |
| ```KF_WEBADMIN_PORT```| Port that WebAdmin will be acessible | ``` Any integer Number ``` | ``` 27015 ``` |
| ```KF_MULTIHOME```| If a server machine can resolve to multiple IP's, this command can tie a server to a specific IP on that machine.  | ``` Server IP Adress ``` ||
| ```KF_PREFERRED_PROCESSOR```| This will tie a server process to a single core/thread on the hosting machine.  | ``` Any integer Number ``` ||
| ```KF_CONFIG_SUB_DIR```| Creates and reads settings from a sub directory under ./KFGame/Config which allows you to configure .INI settings on a per server basis. | ``` Any Alpha numeric character combinations ``` ||

# How to get Workshop ID
![How to get](https://raw.githubusercontent.com/fpetros1/kf2-server/main/resources/how-to-get-workshop-id.png)
