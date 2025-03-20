{ config, ... }:

{
  services.home-assistant.enable = true;
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
        trusted_proxies = [ "127.0.0.1" ];
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
  services.esphome.address = "0.0.0.0";
  services.esphome.usePing = true;

  # Voice assistant
  services.wyoming.faster-whisper.servers."home-assistant" = {

    enable = true;
    language = "de";
    uri = "tcp://0.0.0.0:${toString 10300}";
  };
  services.wyoming.piper.servers."home-assistant" = {

    enable = true;
    voice = "de_DE-thorsten-high";
    uri = "tcp://0.0.0.0:${toString 10200}";
  };

  # Nginx reverse proxy to HomeAssistant with port 8123
  imports = [ ../nginx/basic-auth.nix ];

  services.nginx.enable = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.home-assistant.config.http.server_port}";
    };
    locations."= /api/websocket" = {
      inherit (config.services.nginx.virtualHosts."localhost".locations."/")
        proxyPass
        ;
      proxyWebsockets = true;
    };
    locations."/esphome/" = {
      extraConfig = config.nginx.basic_auth {
        authFile = config.sops.secrets."esphome/basic-auth/auth".path;
        tokenFile = config.sops.templates."esphome/basic-auth/token".path;
      };
      proxyPass = "http://${config.services.esphome.address}:${toString config.services.esphome.port}/";
    };
    locations."~ ^/esphome/(?<path>logs|ace|validate|compile|run|clean)$" = {
      inherit (config.services.nginx.virtualHosts."localhost".locations."/esphome/")
        extraConfig
        ;
      proxyPass = "${
        config.services.nginx.virtualHosts."localhost".locations."/esphome/".proxyPass
      }$path";
      proxyWebsockets = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  # Secrets
  sops.secrets."esphome/basic-auth/auth" = {
    owner = "nginx";
    group = "nginx";
  };
  sops.secrets."esphome/basic-auth/token" = {
    owner = "nginx";
    group = "nginx";
  };
  sops.templates."esphome/basic-auth/token" = {
    content = ''
      set $auth_token "${config.sops.placeholder."esphome/basic-auth/token"}";
    '';
    owner = "nginx";
    group = "nginx";
  };
}
