{ ... }:

let
  VID0 = /dev/video0;
  DATA = /data/octoprint;
in
{
  services.octoprint.enable = true;
  services.octoprint.stateDir = toString DATA;
  services.octoprint.extraConfig = {

    # Camera configuration
    plugins.classicwebcam = {
      snapshot = "http://localhost:5050/?action=snapshot";
      stream = "http://localhost:5050/?action=stream";
    };
  };

  # Camera configuration for OctoPrint
  # Input is specially tuned for the Arducam 1080P Day/Night Vision USB
  services.mjpg-streamer.enable = true;
  services.mjpg-streamer.inputPlugin = "input_uvc.so -d ${toString VID0} -r 1920x1080 -n -br 0 -co 32 -sa 64 -sh 10";
}
