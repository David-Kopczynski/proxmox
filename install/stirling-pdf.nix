{ ... }:

let
  HOST = "pdf.davidkopczynski.com";
  PORT = 44302;
in
{
  services.stirling-pdf.enable = true;
  services.stirling-pdf.environment = {

    # General configuration
    SERVER_PORT = PORT;
    INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true";
  };

  # Nginx reverse proxy to Stirling PDF with custom port
  services.nginx.virtualHosts.${HOST} = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[::1]:${toString PORT}";
      proxyWebsockets = true;
    };
  };
}
