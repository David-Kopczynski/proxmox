{ ... }:

let
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

    ln -s ${toString DATA} /var/lib/private/uptime-kuma
  '';
}
