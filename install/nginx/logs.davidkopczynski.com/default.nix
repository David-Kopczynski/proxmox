{ domain }:
{ config, lib, ... }:

{
  services.grafana.enable = true;
  services.grafana.settings = {

    # General
    server.enforce_domain = true;
    server.domain = domain;

    # Performance
    server.enable_gzip = true;

    # Security
    security.secret_key = "$__file{${config.sops.secrets."grafana/secret".path}}";
  };

  # Source logs and traces
  services.grafana.provision.enable = true;
  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "Loki";
      type = "loki";
      url = "http://${config.services.loki.configuration.server.http_listen_address}:${toString config.services.loki.configuration.server.http_listen_port}";
    }
    {
      name = "Prometheus";
      type = "prometheus";
      access = "proxy";
      url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
    }
  ];

  # Configure Prometheus to source Nginx metrics
  services.prometheus.enable = true;
  services.prometheus = {

    # General
    listenAddress = "127.0.0.1";
    exporters.nginx.enable = true;

    # Scrape
    scrapeConfigs = lib.toList {
      job_name = "nginx";
      static_configs = [ { targets = [ "127.0.0.1:9113" ]; } ];
    };
  };

  # Enable metrics
  services.nginx.statusPage = true;

  # Configure Loki to store logs
  services.loki.enable = true;
  services.loki.configuration = {

    # General
    auth_enabled = false;
    common.replication_factor = 1;
    common.ring.kvstore.store = "inmemory";
    common.ring.instance_addr = "127.0.0.1";
    server.http_listen_address = "127.0.0.1";
    server.http_listen_port = 3100;
    common.path_prefix = "/var/lib/loki";

    # Storage
    storage_config.filesystem = {
      directory = "/var/lib/loki/chunks";
    };
    schema_config.configs = lib.toList {
      schema = "v13";
      from = "1970-01-01";
      store = "tsdb";
      object_store = "filesystem";
      index.prefix = "index_";
      index.period = "24h";
    };
  };

  # Configure Grafana Alloy to scrape Nginx logs
  services.alloy.enable = true;
  environment.etc."alloy/config.alloy".text = ''
    local.file_match "logs" {
      path_targets = [{ __path__ = "/var/log/nginx/*.log", job = "nginx", service_name = "nginx" }]
      sync_period  = "5s"
    }

    loki.source.file "scrape_logs" {
      targets      = local.file_match.logs.targets
      forward_to   = [ loki.write.default.receiver ]
    }

    loki.write "default" {
      endpoint {
        url = "http://${config.services.loki.configuration.server.http_listen_address}:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push"
      }
    }
  '';

  # File permissions
  systemd.services.alloy.serviceConfig.SupplementaryGroups = [ config.users.users."nginx".group ];

  # Nginx reverse proxy to Grafana with port 3000
  services.nginx.virtualHosts.${domain} = {

    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}/";
      proxyWebsockets = true;
    };
  };

  # Secrets
  sops.secrets."grafana/secret" = {
    sopsFile = ./secrets.yaml;
    owner = config.users.users."grafana".name;
    group = config.users.users."grafana".group;
  };
}
