FROM debian:jessie
MAINTAINER zealic <zealic@gmail.com>

RUN dpkg --add-architecture i386 && apt-get update \
  && apt-get install -y curl lib32gcc1 lib32stdc++6 libgcc1 libcurl4-gnutls-dev:i386 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -u 10999 -m steam
RUN mkdir /DST \
  && chown steam:steam /DST \
  && mkdir -p /home/steam/.klei \
  && chown -R steam:steam /home/steam/.klei

USER steam
RUN mkdir ~/steamcmd
ENV DST_SERVER_VERSION 159550
RUN cd  ~/steamcmd && curl -SLO "http://media.steampowered.com/installer/steamcmd_linux.tar.gz" \
  && tar -xvf steamcmd_linux.tar.gz -C ~/steamcmd && rm steamcmd_linux.tar.gz
RUN ~/steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/steam/steamapps/DST +app_update 343050 validate +quit
RUN echo "ServerModCollectionSetup(\"578746221\")" > /home/steam/steamapps/DST/mods/dedicated_server_mods_setup.lua
RUN echo "ForceEnableMod(\"workshop-563315405\")\nForceEnableMod(\"workshop-347360448\")\nForceEnableMod(\"workshop-358749986\")\nForceEnableMod(\"workshop-375859599\")\nForceEnableMod(\"workshop-345692228\")\n" > /home/steam/steamapps/DST/mods/modsettings.lua
RUN echo "ForceEnableMod(\"workshop-563315405\")\nForceEnableMod(\"workshop-347360448\")\nForceEnableMod(\"workshop-358749986\")\nForceEnableMod(\"workshop-375859599\")\nForceEnableMod(\"workshop-345692228\")\nForceEnableMod(\"workshop-569043634\")\nForceEnableMod(\"workshop-351325790\")\nForceEnableMod(\"workshop-362022168\")\nForceEnableMod(\"workshop-463718554\")\nForceEnableMod(\"workshop-378160973\")\n" > /home/steam/steamapps/DST/mods/modsettings.lua
RUN echo "return { override_enabled = true, unprepared = { berrybush = \"default\", cactus = \"default\", carrot = \"default\", mushroom = \"default\" }, misc = { task_set = \"classic\", start_location = \"default\", autumn = \"default\", boons = \"default\", branching = \"default\", day = \"default\", frograin = \"default\", lightning = \"default\", loop = \"default\", season_start = \"default\", spring = \"default\", summer = \"default\", touchstone = \"default\", weather = \"default\", wildfires = \"default\", winter = \"default\", world_size = \"huge\" }, animals = { alternatehunt = \"default\", angrybees = \"default\", beefalo = \"default\", beefaloheat = \"default\", bees = \"default\", birds = \"default\", butterfly = \"default\", buzzard = \"default\", catcoon = \"default\", frogs = \"default\", hunt = \"default\", lightninggoat = \"default\", moles = \"default\", penguins = \"default\", perd = \"default\", pigs = \"default\", rabbits = \"default\", tallbirds = \"default\" }, monsters = { bearger = \"default\", chess = \"default\", deciduousmonster = \"default\", deerclops = \"default\", dragonfly = \"default\", goosemoose = \"default\", houndmound = \"default\", hounds = \"default\", krampus = \"default\", liefs = \"default\", lureplants = \"default\", merm = \"default\", spiders = \"default\", tentacles = \"default\", walrus = \"default\" }, resources = { flint = \"default\", flowers = \"default\", grass = \"default\", marshbush = \"default\", meteorshowers = \"default\", meteorspawner = \"default\", reeds = \"default\", rock = \"default\", rock_ice = \"default\", sapling = \"default\", trees = \"default\", tumbleweed = \"default\"}}"
RUN ~/steamcmd/steamcmd.sh +login anonymous +app_update 343050 validate +quit

USER root
ADD ./bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/run-dst
RUN echo "#!/bin/bash\ncd /home/steam/steamcmd\n./steamcmd.sh +login anonymous +app_update 343050 validate +quit\n" > /etc/init.d/update_mods.sh

USER steam
EXPOSE 10999/udp
VOLUME ["/DST"]
ENTRYPOINT ["/usr/local/bin/run-dst"]
