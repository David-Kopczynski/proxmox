{ ... }:
{ config, ... }:

{
  services.octoprint.enable = true;
  services.octoprint = {

    # Additional plugins
    plugins =
      p: with p; [
        firmwareupdater
        printtimegenius
        prusaslicerthumbnails
        telegram
      ];

    extraConfig = {

      # General configuration
      appearance.name = "Prusa-Printer";
      folder.timelapse = toString /data/timelapse;
      serialDevice = "/dev/ttyACM0";
      serial.autoconnect = true;
      server.commands.serverRestartCommand = "systemctl restart octoprint.service";
      server.onlineCheck.enabled = false;
      tracking.enabled = false;
      webcam.watermark = false;

      # Camera configuration
      plugins.classicwebcam = {
        snapshot = "http://127.0.0.1:5050/?action=snapshot";
        stream = "/webcam/?action=stream";
      };
    };
  };

  # Camera configuration for OctoPrint
  # Input is specially tuned for the Arducam 1080P Day/Night Vision USB
  services.mjpg-streamer.enable = true;
  services.mjpg-streamer.inputPlugin = "input_uvc.so -d ${toString /dev/video0} -r 1920x1080 -n -br 0 -co 32 -sa 64 -sh 10";
  services.mjpg-streamer.outputPlugin = "output_http.so -p 5050 -w @www@ -n";

  # Nginx reverse proxy to OctoPrint with port 5000
  imports = [ ../nginx/basic-auth.nix ];

  services.nginx.enable = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.octoprint.port}";
    };
    locations."/sockjs/" = {
      inherit (config.services.nginx.virtualHosts."localhost".locations."/")
        proxyPass
        ;
      proxyWebsockets = true;
    };
    locations."/webcam/" = {
      extraConfig = config.nginx.basic_auth {
        authFile = config.sops.secrets."basic-auth/auth".path;
        tokenFile = config.sops.templates."basic-auth/token".path;
      };
      proxyPass = "http://127.0.0.1:5050/";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  # Secrets
  sops.secrets."basic-auth/auth" = {
    owner = "nginx";
    group = "nginx";
  };
  sops.secrets."basic-auth/token" = {
    owner = "nginx";
    group = "nginx";
  };
  sops.templates."basic-auth/token" = {
    content = ''
      set $auth_token "${config.sops.placeholder."basic-auth/token"}";
    '';
    owner = "nginx";
    group = "nginx";
  };
}
