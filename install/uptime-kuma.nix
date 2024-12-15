{ ... }:

{
  services.uptime-kuma.enable = true;
  services.uptime-kuma.settings = {

    # Data directory cannot be changed
    # DATA_DIR = "/var/lib/private/uptime-kuma";
    PORT = "44301";
  };

  # Manually symlink data directory as it cannot be changed
  # /var/lib/private/uptime-kuma -> /data/uptime-kuma
  system.activationScripts.uptime-kuma = ''
    mkdir -p /var/lib/private
    chmod 700 /var/lib/private

    ln -s /data/uptime-kuma /var/lib/private/uptime-kuma
  '';
}
