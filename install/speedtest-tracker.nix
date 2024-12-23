{ config, ... }:

let
  HOST = "speed.davidkopczynski.com";
  PORT = 44303;
  DATA = /data/speedtest-tracker;
in
{
  virtualisation.containers.enable = true;
  virtualisation.oci-containers.containers."speedtest-tracker" = {
    image = "lscr.io/linuxserver/speedtest-tracker:latest";
    autoStart = true;
    ports = [ "${toString PORT}:80" ];
    volumes = [ "${toString DATA}:/config" ];
    environment = {
      APP_URL = "https://${HOST}";
      DB_CONNECTION = "sqlite";
      SPEEDTEST_SCHEDULE = "*/10 * * * *";
      PRUNE_RESULTS_OLDER_THAN = "0";
      DISPLAY_TIMEZONE = config.time.timeZone;
    };
    environmentFiles = [ "${toString DATA}/secrets.env" ];
  };
}
