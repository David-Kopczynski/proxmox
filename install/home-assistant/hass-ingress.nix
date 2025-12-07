{ buildHomeAssistantComponent, fetchFromGitHub, ... }:

buildHomeAssistantComponent rec {
  owner = "lovelylain";
  version = "1.2.9";
  domain = "ingress";

  src = fetchFromGitHub {
    inherit owner;
    repo = "hass_ingress";
    rev = version;
    hash = "sha256-jjig0Dl/vdeuN7e25CH5L/Xvc60RM3BiAt3jUw/C9q4=";
  };
}
