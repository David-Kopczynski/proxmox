{ ... }:

let
  HOST = "patch.davidkopczynski.com";
  MOVE = "https://www.rwth-aachen.de/global/show_document.asp?id=aaaaaaaaaaajyav";
in
{
  # Redirect patch. to page of my choice
  services.nginx.virtualHosts.${HOST} = {
    forceSSL = true;
    globalRedirect = MOVE;
    redirectCode = 302;
  };
}
