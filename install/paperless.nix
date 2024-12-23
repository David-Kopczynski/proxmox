{ ... }:

let
  HOST = "archive.davidkopczynski.com";
  DATA = /data/paperless;
in
{
  services.paperless.enable = true;
  services.paperless.dataDir = toString DATA;
  services.paperless.address = HOST;
  services.paperless.settings = {

    # Custom settings for my optimal setup
    PAPERLESS_OCR_LANGUAGE = "deu+eng";
    PAPERLESS_OCR_USER_ARGS = {

      # This prevents failure when PDF is signed
      invalidate_digital_signatures = true;
    };
  };
}
