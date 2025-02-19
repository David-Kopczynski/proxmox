{ config, ... }:

let
  HOST = "home.davidkopczynski.com";
  WHSP = 10300;
  PIPR = 10200;
  DATA = /data/home-assistant;
in
{
  services.home-assistant.enable = true;
  services.home-assistant.configDir = toString (DATA + "/config");
  services.home-assistant = {

    # Additional components
    extraComponents = [
      "default_config"
      "esphome"
      "isal"
      "met"
      "mobile_app"
      "piper"
      "sun"
      "whisper"
      "wyoming"
    ];

    # General configuration
    # This is taken from the configuration.yaml file
    config = {

      default_config = { };

      # Additional lovelace resources
      lovelace = {
        mode = "yaml";
        resources = [ ];
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
    };
  };

  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 644 hass hass"
    "f ${config.services.home-assistant.configDir}/rest_command.yaml 644 hass hass"
    "f ${config.services.home-assistant.configDir}/scenes.yaml 644 hass hass"
    "f ${config.services.home-assistant.configDir}/scripts.yaml 644 hass hass"
  ];

  # Enable ESPHome for HomeAssistant
  services.esphome.enable = true;
  services.esphome.address = "127.0.0.1";
  services.esphome.usePing = true;

  # Manually symlink data directory as it cannot be changed
  # /var/lib/private/esphome -> /data/home-assistant/esphome
  system.activationScripts.esphome = ''
    mkdir -p /var/lib/private
    chmod 700 /var/lib/private

    rm -rf /var/lib/private/esphome
    ln -s ${toString (DATA + "/esphome")} /var/lib/private/esphome
  '';

  # Voice assistant
  services.wyoming.faster-whisper.servers."home-assistant" = {

    enable = true;
    language = "de";
    uri = "tcp://0.0.0.0:${toString WHSP}";
  };
  services.wyoming.piper.servers."home-assistant" = {

    enable = true;
    voice = "de_DE-thorsten-high";
    uri = "tcp://0.0.0.0:${toString PIPR}";
  };

  # Nginx reverse proxy to HomeAssistant with port 8123
  services.nginx.virtualHosts.${HOST} = {

    inherit (config.cloudflare)
      extraConfig
      sslCertificate
      sslCertificateKey
      ;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.home-assistant.config.http.server_port}/";
    };
    locations."= /api/websocket" = {
      proxyPass = "http://127.0.0.1:${toString config.services.home-assistant.config.http.server_port}/api/websocket";
      proxyWebsockets = true;
    };
    locations."/esphome/" = {
      extraConfig = config.nginx.basic_auth {
        authFile = DATA + "/esphome.auth";
        tokenFile = DATA + "/esphome.token";
      };
      proxyPass = "http://${config.services.esphome.address}:${toString config.services.esphome.port}/";
    };
    locations."~ ^/esphome/(?<path>logs|ace|validate|compile|run|clean)$" = {
      inherit (config.services.nginx.virtualHosts.${HOST}.locations."/esphome/")
        extraConfig
        ;
      proxyPass = "http://${config.services.esphome.address}:${toString config.services.esphome.port}/$path";
      proxyWebsockets = true;
    };
  };
}
