{ ... }:
{ config, pkgs, ... }:

{
  services.home-assistant.enable = true;
  services.home-assistant = {

    # Additional components
    extraComponents = [
      "default_config"
      "esphome"
      "isal"
      "matter"
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

      # Load different sensitive or ui driven configuration
      automation = "!include automations.yaml";
      rest_command = "!include rest_command.yaml";
      scene = "!include scenes.yaml";
      script = "!include scripts.yaml";

      # HTTP configuration for reverse proxy
      http = {
        server_host = "127.0.0.1";
        trusted_proxies = [
          "127.0.0.0/8"
          "10.0.0.0/8"
          "172.16.0.0/12"
          "192.168.0.0/16"
        ];
        use_x_forwarded_for = true;
      };
    };

    # Additional lovelace modules
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      mini-graph-card
    ];

    # Lovelace configuration
    # This only loads the modules for use with the default views
    lovelaceConfig = { };

    # Postgres Support
    extraPackages = ps: with ps; [ psycopg2 ];
    config.recorder.db_url = "postgresql://@/hass";
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

  # Enable Matter-Server
  services.matter-server.enable = true;
  services.matter-server.extraArgs = [ "--enable-test-net-dcl" ];

  # Voice assistant
  services.wyoming.faster-whisper.servers."home-assistant" = {

    enable = true;
    language = "de";
    uri = "tcp://127.0.0.1:${toString 10300}";
  };
  services.wyoming.piper.servers."home-assistant" = {

    enable = true;
    voice = "de_DE-thorsten-high";
    uri = "tcp://127.0.0.1:${toString 10200}";
  };

  services.wyoming.openwakeword.enable = true;
  services.wyoming.openwakeword.uri = "tcp://127.0.0.1:${toString 10400}";

  # Postgres database
  services.postgresql.enable = true;
  services.postgresql.ensureDatabases = [ "hass" ];
  services.postgresql.ensureUsers = [ ({ name = "hass"; } // { ensureDBOwnership = true; }) ];

  # Nginx reverse proxy to HomeAssistant with port 8123
  imports = [ ../nginx/proxy-pass.websockets.nix ] ++ [ ../nginx/basic-auth.nix ];

  services.nginx.enable = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      extraConfig = config.nginx.proxyWebsocketsConfig;
      proxyPass = "http://${config.services.home-assistant.config.http.server_host}:${toString config.services.home-assistant.config.http.server_port}/";
      proxyWebsockets = true;
    };
    locations."/esphome/" = {
      extraConfig = ''
        ${config.services.nginx.virtualHosts."localhost".locations."/".extraConfig}

        ${config.nginx.basic_auth {
          authFile = config.sops.secrets."esphome/basic-auth/auth".path;
          tokenFile = config.sops.templates."esphome/basic-auth/token".path;
        }}
      '';
      proxyPass = "http://${config.services.esphome.address}:${toString config.services.esphome.port}/";
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
