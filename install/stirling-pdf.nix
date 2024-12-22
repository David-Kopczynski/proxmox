{ ... }:

let
  PORT = 44302;
in
{
  services.stirling-pdf.enable = true;
  services.stirling-pdf.environment = {

    # General configuration
    SERVER_PORT = PORT;
    INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true";
  };
}
