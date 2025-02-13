{ config, lib, ... }:

let
  HOST = "home.davidkopczynski.com";
  ADDR = "192.168.0.39";
  PORT = 8300;
  DATA = /data/home-assistant;
in
{
  services.home-assistant.enable = true;
  services.home-assistant.configDir = toString (DATA + "/config");
  services.home-assistant = {

    # Additional components
    extraComponents = [
      "default_config"
      "emulated_hue"
      "esphome"
      "isal"
      "met"
      "mobile_app"
      "sun"
    ];

    # General configuration
    # This is taken from the configuration.yaml file
    config = {

      default_config = { };

      # Load frontend themes from the themes folder
      frontend = {
        themes = "!include_dir_merge_named themes";
      };

      # Load different sensitive or ui driven configuration
      automation = "!include automations.yaml";
      rest_command = "!include rest_command.yaml";
      scene = "!include scenes.yaml";
      script = "!include scripts.yaml";

      # HTTP configuration for reverse proxy
      http = {
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
        use_x_forwarded_for = true;
      };

      # Alexa support using Emulated Hue
      emulated_hue = {
        host_ip = ADDR;
        listen_port = PORT;
        expose_by_default = false;
        entities = "!include emulated_hue.yaml";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 644 hass hass"
    "f ${config.services.home-assistant.configDir}/rest_command.yaml 644 hass hass"
    "f ${config.services.home-assistant.configDir}/scenes.yaml 644 hass hass"
    "f ${config.services.home-assistant.configDir}/scripts.yaml 644 hass hass"
    "f ${config.services.home-assistant.configDir}/emulated_hue.yaml 644 hass hass"
  ];

  # Enable ESPHome for HomeAssistant
  services.esphome.enable = true;
  services.esphome.usePing = true;

  # Manually symlink data directory as it cannot be changed
  # /var/lib/private/esphome -> /data/home-assistant/esphome
  system.activationScripts.esphome = ''
    mkdir -p /var/lib/private
    chmod 700 /var/lib/private

    rm -rf /var/lib/private/esphome
    ln -s ${toString (DATA + "/esphome")} /var/lib/private/esphome
  '';

  # Configure emulated hue
  services.nginx.virtualHosts.${ADDR} = {

    forceSSL = false;
    locations."/description.xml" = {
      proxyPass = "http://${ADDR}:${toString PORT}/description.xml";
    };
    locations."/api/" = {
      proxyPass = "http://${ADDR}:${toString PORT}/api/";
    };
  };

  networking.firewall.allowedTCPPorts = [ PORT ];

  # Nginx reverse proxy to HomeAssistant with port 8123
  services.nginx.virtualHosts.${HOST} = {

    inherit (config.cloudflare)
      extraConfig
      sslCertificate
      sslCertificateKey
      sslTrustedCertificate
      ;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.home-assistant.config.http.server_port}/";
      proxyWebsockets = true;
    };
    locations."/esphome/" = {
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

        include ${toString (DATA + "/esphome.token")};
        if ($cookie_auth_basic_token = $esphome_token) { set $esphome_passed success; }
        auth_basic $auth_basic_esphome;
        auth_basic_user_file ${toString (DATA + "/esphome.auth")};
        add_header Set-Cookie "auth_basic_token=$esphome_token; Path=/; Max-Age=2628000; SameSite=strict; Secure; HttpOnly;";
      '';
      proxyPass = "http://${config.services.esphome.address}:${toString config.services.esphome.port}/";
      proxyWebsockets = true;
    };
  };

  services.nginx.appendHttpConfig = ''
    map $esphome_passed $auth_basic_esphome {
      success off;
      default secured;
    }
  '';
}
