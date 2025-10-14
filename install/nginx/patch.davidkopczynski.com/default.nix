{ domain }:
{ ... }:

{
  # Redirect patch to page of my choice
  services.nginx.virtualHosts.${domain} = {

    enableACME = true;
    forceSSL = true;
    locations."/" = {
      return = "302 https://www.rwth-aachen.de/global/show_document.asp?id=aaaaaaaaaaajyav";
    };
  };
}
