{ config, lib, ... }:

{
  # Auth request for domains with target app, auth and current location
  options.nginx.auth_request = with lib; mkOption { type = types.functionTo types.str; };
  config.nginx.auth_request =
    {
      app,
      auth,
      base,
    }:
    ''
      ${config.services.nginx.appendHttpConfig}

      auth_request     ${base}/.nginx/auth_request;
      auth_request_set $auth_status $upstream_status;

      location = ${base}/.nginx/auth_request {
        internal;
        proxy_pass              ${app}${auth};
        proxy_pass_request_body off;
        proxy_set_header        Content-Length "";
        proxy_set_header        X-Original-URI $request_uri;
      }
    '';
}
