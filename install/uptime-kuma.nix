{ config, ... }:

let
  HOST = "davidkopczynski.com";
  PORT = 44301;
  DATA = /data/uptime-kuma;
in
{
  services.uptime-kuma.enable = true;
  services.uptime-kuma = {

    # General configuration
    appriseSupport = true;

    settings = {

      # Data directory cannot be changed
      # DATA_DIR = "/var/lib/private/uptime-kuma";
      PORT = toString PORT;
    };
  };

  # Manually symlink data directory as it cannot be changed
  # /var/lib/private/uptime-kuma -> /data/uptime-kuma
  system.activationScripts.uptime-kuma = ''
    mkdir -p /var/lib/private
    chmod 700 /var/lib/private

    rm -rf /var/lib/private/uptime-kuma
    ln -s ${toString DATA} /var/lib/private/uptime-kuma
  '';

  # Nginx reverse proxy to Uptime Kuma with custom port
  services.nginx.virtualHosts.${HOST} = {
    default = true;

    inherit (config.cloudflare)
      extraConfig
      sslCertificate
      sslCertificateKey
      ;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString PORT}/";
    };
    locations."= /socket.io/" = {
      proxyPass = "http://127.0.0.1:${toString PORT}/socket.io/";
      proxyWebsockets = true;
    };
  };
}
