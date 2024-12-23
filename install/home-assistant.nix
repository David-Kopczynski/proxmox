{ ... }:

let
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
      script = "!include scripts.yaml";
      scene = "!include scenes.yaml";

      # HTTP configuration for reverse proxy
      http = {
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };

      # Shell commands
      shell_command = {
        "webhook_export_co2_david_to_lars" = "bash shell/webhook_export_co2_david_to_lars.sh";
        "webhook_export_co2_david_to_levin" = "bash shell/webhook_export_co2_david_to_levin.sh";
        "webhook_export_co2_erik_to_lars" = "bash shell/webhook_export_co2_erik_to_lars.sh";
      };

      # Alexa Support using Emulated Hue
      emulated_hue = {
        host_ip = ADDR;
        listen_port = 80;
        expose_by_default = false;
        entities = {
          "light.esphome_web_dfc8f0_licht_david" = {
            name = "David";
            hidden = false;
          };
          "light.esphome_web_dfc8f0_licht_bad" = {
            name = "Bad";
            hidden = false;
          };
          "light.esphome_web_dfc8f0_licht_erik" = {
            name = "Erik";
            hidden = false;
          };
          "light.esphome_web_dfc8f0_licht_flur" = {
            name = "Flur";
            hidden = false;
          };
          "light.esphome_web_dfc8f0_licht_kammer" = {
            name = "Kammer";
            hidden = false;
          };
          "light.esphome_web_dfc8f0_licht_kueche" = {
            name = "Kueche";
            hidden = false;
          };
          "input_boolean.alexa_pc_toggle" = {
            name = "PC";
            hidden = false;
          };
        };
      };
    };
  };

  # Enable ESPHome for HomeAssistant
  services.esphome.enable = true;
}
