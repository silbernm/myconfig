{ pkgs, ... }:
# see: https://wiki.ubuntuusers.de/Spiele/Doom_3/
{ config = {
    home-manager.users.mhuber =
      { home.packages = with pkgs; [ dhewm3 ];
      };
  };
}
