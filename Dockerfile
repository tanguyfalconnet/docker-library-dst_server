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
ENV DST_SERVER_VERSION 161456
RUN cd  ~/steamcmd && curl -SLO "http://media.steampowered.com/installer/steamcmd_linux.tar.gz" \
  && tar -xvf steamcmd_linux.tar.gz -C ~/steamcmd && rm steamcmd_linux.tar.gz
RUN ~/steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/steam/steamapps/DST +app_update 343050 validate +quit
RUN echo "ServerModCollectionSetup(\"578746221\")" > /home/steam/steamapps/DST/mods/dedicated_server_mods_setup.lua
RUN ~/steamcmd/steamcmd.sh +login anonymous +app_update 343050 validate +quit

USER root
ADD ./bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/run-dst
RUN echo "#!/bin/bash\ncd /home/steam/steamcmd\n./steamcmd.sh +login anonymous +app_update 343050 validate +quit\n" > /etc/init.d/update_mods.sh
RUN chmod +x /etc/init.d/update_mods.sh
RUN chown steam /etc/init.d/update_mods.sh

USER steam
EXPOSE 10999/udp
VOLUME ["/DST"]
ENTRYPOINT ["/usr/local/bin/run-dst"]
