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
    volumes = [ "${toString (DATA + "/config")}:/config" ];
    environment = {
      APP_URL = "https://${HOST}";
      DB_CONNECTION = "sqlite";
      SPEEDTEST_SCHEDULE = "0 * * * *";
      PRUNE_RESULTS_OLDER_THAN = "0";
      DISPLAY_TIMEZONE = config.time.timeZone;
    };
    environmentFiles = [ (toString (DATA + "/secrets.env")) ];
  };

  # Nginx reverse proxy to Speedtest Tracker with custom port
  services.nginx.virtualHosts.${HOST} = {

    inherit (config.cloudflare)
      extraConfig
      sslCertificate
      sslCertificateKey
      ;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString PORT}/";
      proxyWebsockets = true;
    };
  };
}
