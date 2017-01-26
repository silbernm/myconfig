{ config, pkgs, ... }:

let
  unstable = (import <unstable> {});
in {
  environment.systemPackages = with pkgs; [
    unstable.slock unstable.dmenu unstable.unclutter
  ] ++ (with unstable.haskellPackages; [
    xmonad xmobar yeganesh
  ]);

  services.xserver = {
    windowManager = {
      xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };
      # i3.enable = true;
      default = "xmonad";
    };

    desktopManager = {
      xterm.enable = false;
      default = "none";
    };

    displayManager.slim = {
      enable = true;
      defaultUser = "mhuber";
    };
  };
}
