{ ... }:
{ config, ... }:

{
  services.stirling-pdf.enable = true;
  services.stirling-pdf.environment = {

    # General configuration
    INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true";
    SERVER_PORT = 3000;
  };

  # Nginx reverse proxy to Stirling PDF with custom port 3000
  services.nginx.enable = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.stirling-pdf.environment.SERVER_PORT}/";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
