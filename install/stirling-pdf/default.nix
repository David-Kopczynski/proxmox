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
  services.nginx.enable = true;
  services.nginx.virtualHosts."localhost" = {

    locations."/" = {
      extraConfig = ''
        client_max_body_size 1G;
      '';
      proxyPass = "http://${config.services.stirling-pdf.environment.SERVER_ADDRESS}:${config.services.stirling-pdf.environment.SERVER_PORT}/";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
