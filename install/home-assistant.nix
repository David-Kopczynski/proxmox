{ config, ... }:

let
  HOST = "home.davidkopczynski.com";
  ADDR = "192.168.0.39";
  DATA = /data/home-assistant;
in
{
  services.home-assistant.enable = true;
  services.home-assistant.configDir = toString DATA;
  services.home-assistant = {

    # Additional components
    extraComponents = [
      "default_config"
      "emulated_hue"
      "esphome"
      "met"
      "mobile_app"
      "sun"
    ];

    # General configuration
    # This is taken from the configuration.yaml file
    config = {

      default_config = { };

      # Load frontend themes from the themes folder
      # This may render errors when the files do not exist yet
      frontend = {
        themes = "!include_dir_merge_named themes";
      };

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
        listen_port = 8300;
        expose_by_default = false;
        entities = "!include emulated_hue.yaml";
      };
    };
  };

  # Enable ESPHome for HomeAssistant
  services.esphome.enable = true;

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
      extraConfig = ''
        proxy_buffering off;
      '';
      proxyPass = "http://localhost:${toString config.services.home-assistant.config.http.server_port}";
      proxyWebsockets = true;
    };
  };
}
