{ config, ... }:

let
  HOST = "printer.davidkopczynski.com";
  VID0 = /dev/video0;
  PORT = 5050;
  DATA = /data/octoprint;
in
{
  services.octoprint.enable = true;
  services.octoprint.stateDir = toString (DATA + "/config");
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
      serialDevice = "/dev/ttyACM0";
      serial.autoconnect = true;
      server.commands.serverRestartCommand = "systemctl restart octoprint.service";
      server.onlineCheck.enabled = false;
      tracking.enabled = false;
      webcam.watermark = false;

      # Camera configuration
      plugins.classicwebcam = {
        snapshot = "http://127.0.0.1:${toString PORT}/?action=snapshot";
        stream = "/webcam/?action=stream";
      };
    };
  };

  # Camera configuration for OctoPrint
  # Input is specially tuned for the Arducam 1080P Day/Night Vision USB
  services.mjpg-streamer.enable = true;
  services.mjpg-streamer.inputPlugin = "input_uvc.so -d ${toString VID0} -r 1920x1080 -n -br 0 -co 32 -sa 64 -sh 10";
  services.mjpg-streamer.outputPlugin = "output_http.so -p ${toString PORT} -w @www@ -n";

  # Nginx reverse proxy to OctoPrint with port 5000
  services.nginx.virtualHosts.${HOST} = {

    inherit (config.cloudflare)
      extraConfig
      sslCertificate
      sslCertificateKey
      ;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.octoprint.port}";
    };
    locations."/sockjs/" = {
      inherit (config.services.nginx.virtualHosts.${HOST}.locations."/")
        proxyPass
        ;
      proxyWebsockets = true;
    };
    locations."/webcam/" = {
      extraConfig = config.nginx.basic_auth {
        authFile = DATA + "/streamer.auth";
        tokenFile = DATA + "/streamer.token";
      };
      proxyPass = "http://127.0.0.1:${toString PORT}/";
    };
  };
}
