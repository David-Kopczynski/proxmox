{ config, lib, ... }:

{
  # Basic authentication for domains with tokenFile and authFile
  options.nginx.basic_auth = with lib; mkOption { type = types.functionTo types.str; };
  config.nginx.basic_auth =
    { tokenFile, authFile }:
    ''
      ${config.services.nginx.appendHttpConfig}

      set $basic_auth secured;

      include ${toString tokenFile};
      if ($cookie_auth_basic_token = $auth_token) { set $basic_auth off; }

      auth_basic $basic_auth;
      auth_basic_user_file ${toString authFile};

      add_header Set-Cookie "auth_basic_token=$auth_token; Path=/; Max-Age=2628000; SameSite=strict; Secure; HttpOnly;";
    '';
}
