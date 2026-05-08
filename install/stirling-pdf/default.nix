{ ... }:
{ config, ... }:

{
  services.stirling-pdf.enable = true;
  services.stirling-pdf.environment = {

    # General configuration
    SERVER_ADDRESS = "127.0.0.1";
    SERVER_PORT = toString 3000;

    INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true";
  };

  # Nginx reverse proxy to Stirling PDF with custom port 3000
  imports = [ ../nginx/proxy-pass.client.nix ];

  services.nginx.enable = true;
  services.nginx = {

    # General configuration
    recommendedOptimisation = true;
    recommendedProxySettings = true;

    # Recommended settings from https://docs.stirlingpdf.com/Production-Deployment-Guide/
    clientMaxBodySize = "1G";
    proxyTimeout = "300s";
  };
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      proxyPass = "http://${config.services.stirling-pdf.environment.SERVER_ADDRESS}:${config.services.stirling-pdf.environment.SERVER_PORT}/";
      proxyWebsockets = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
