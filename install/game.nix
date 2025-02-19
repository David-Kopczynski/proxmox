{
  config,
  lib,
  pkgs,
  ...
}:

let
  HOST = "game.davidkopczynski.com";
  DATA = /data/game;
in
{
  services.nginx.virtualHosts.${HOST} = {

    inherit (config.cloudflare)
      extraConfig
      sslCertificate
      sslCertificateKey
      ;
    forceSSL = true;
    locations = lib.mkMerge [
      {
        "/".root = toString DATA;
      }
      (lib.attrsets.concatMapAttrs
        (file: application_type: {
          ${file} = {
            # Special configuration for compressed files when using Unity's WebGL build
            extraConfig = ''
              include ${pkgs.writeText "unity-compression" ''
                ${
                  let
                    configFromList = lib.strings.concatStringsSep "\n" (proxyHideHeaderLines ++ addHeaderLines);
                    proxyHideHeaderLines = builtins.filter (lib.strings.hasPrefix "proxy_hide_header") httpToList;
                    addHeaderLines = builtins.filter (lib.strings.hasPrefix "add_header") httpToList;
                    httpToList = lib.strings.splitString "\n" config.services.nginx.appendHttpConfig;
                  in
                  configFromList
                }

                brotli off;
                gzip off;
                zstd off;

                add_header Content-Encoding br;
              ''};

              ${application_type}
            '';
            root = toString DATA;
          };
        })
        {
          "~ .+\\.(data|symbols\\.json)\\.br$" = "default_type application/octet-stream;";
          "~ .+\\.js\\.br$" = "default_type application/javascript;";
          "~ .+\\.wasm\\.br$" = "default_type application/wasm;";
        }
      )
    ];
  };
}
