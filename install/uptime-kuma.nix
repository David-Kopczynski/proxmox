{ ... }:

{
  services.uptime-kuma.enable = true;
  services.uptime-kuma.settings = {

    # Data directory cannot be changed
    # DATA_DIR = "/var/lib/private/uptime-kuma";
    PORT = "44301";
  };
}
