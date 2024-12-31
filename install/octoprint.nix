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
  services.octoprint.extraConfig = {

    # Printer configuration
    serialDevice = "/dev/ttyACM0";

    # Camera configuration
    plugins.classicwebcam = {
      snapshot = "http://localhost:${toString PORT}/?action=snapshot";
      stream = "/webcam";
    };

    # System configuration
    server.commands = {
      serverRestartCommand = "systemctl restart octoprint.service";
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
      sslTrustedCertificate
      ;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.octoprint.port}";
      proxyWebsockets = true;
    };
    locations."/webcam/" = {
      basicAuthFile = toString (DATA + "/streamer.auth");
      proxyPass = "http://localhost:${toString PORT}/?action=stream";
    };
  };
}
