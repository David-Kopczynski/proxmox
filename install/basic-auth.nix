{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Basic authentication for domains with tokenFile and authFile
  options.nginx.basic_auth = with lib; mkOption { type = types.functionTo types.str; };
  config.nginx.basic_auth =
    { tokenFile, authFile }:
    ''
      include ${pkgs.writeText "basic-auth" ''
        ${
          let
            configFromList = lib.strings.concatStringsSep "\n" (proxyHideHeaderLines ++ addHeaderLines);
            proxyHideHeaderLines = builtins.filter (lib.strings.hasPrefix "proxy_hide_header") httpToList;
            addHeaderLines = builtins.filter (lib.strings.hasPrefix "add_header") httpToList;
            httpToList = lib.strings.splitString "\n" config.services.nginx.appendHttpConfig;
          in
          configFromList
        }

        include ${toString tokenFile}; # includes the $auth_token
        if ($cookie_auth_basic_token = $auth_token) { set $basic_auth_passed success; }

        auth_basic $basic_auth;
        auth_basic_user_file ${toString authFile};

        add_header Set-Cookie "auth_basic_token=$auth_token; Path=/; Max-Age=2628000; SameSite=strict; Secure; HttpOnly;";
      ''};
    '';

  config.services.nginx.appendHttpConfig = ''
    map $basic_auth_passed $basic_auth {
      success off;
      default secured;
    }
  '';
}
