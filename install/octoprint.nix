{ config, lib, ... }:

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
      proxyPass = "http://localhost:${toString config.services.octoprint.port}/";
      proxyWebsockets = true;
    };
    locations."/webcam/" = {
      extraConfig = ''
        ${
          let
            configFromList = lib.strings.concatStringsSep "\n" (proxyHideHeaderLines ++ addHeaderLines);
            proxyHideHeaderLines = builtins.filter (lib.strings.hasPrefix "proxy_hide_header") httpToList;
            addHeaderLines = builtins.filter (lib.strings.hasPrefix "add_header") httpToList;
            httpToList = lib.strings.splitString "\n" config.services.nginx.appendHttpConfig;
          in
          configFromList
        }

        include ${toString (DATA + "/streamer.token")};
        if ($cookie_auth_basic_token = $streamer_token) { set $streamer_passed success; }
        auth_basic $auth_basic_streamer;
        auth_basic_user_file ${toString (DATA + "/streamer.auth")};
        add_header Set-Cookie "auth_basic_token=$streamer_token; Path=/; Max-Age=2628000; SameSite=strict; Secure; HttpOnly;";
      '';
      proxyPass = "http://localhost:${toString PORT}/?action=stream/";
    };
  };

  services.nginx.appendHttpConfig = ''
    map $streamer_passed $auth_basic_streamer {
      success off;
      default secured;
    }
  '';
}
