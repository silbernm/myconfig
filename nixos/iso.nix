# see also: https://nixos.mayflower.consulting/blog/2018/09/11/custom-images/
{ system ? "x86_64-linux"
, hostName ? "dev"
, secondaryHostName ? hostName }:
let
  nixpkgs = ../nixpkgs;
  preBuiltConfig = (import ../nixpkgs/nixos {
    configuration = import (./. + hostName) {
      pkgs = nixpkgs;
    };
  }).system;
  myisoconfig = { ... }: {
    imports = [
      "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
      (./. + "/${hostName}")
      ./headless/modules/service.openssh.nix
    ];

    config = {
      networking.hostName = "myconfig";
      networking.wireless.enable = false;

      environment.systemPackages = if hostName == secondaryHostName
                                   then []
                                   else [ preBuiltConfig ];

      # add myconfig to iso
      isoImage.contents = [
        # folders
        { source = ./.; target = "myconfig/nixos"; }
        { source = ../misc; target = "myconfig/misc"; }
        { source = ../nixpkgs; target = "myconfig/nixpkgs"; }
        # files
        { source = ../common.sh; target = "myconfig/common.sh"; }
        { source = ../rebuild.sh; target = "myconfig/rebuild.sh"; }
        { source = ../README.org; target = "myconfig/README.org"; }
        { source = ../LICENSE; target = "myconfig/LICENSE"; }
      ];
    };
  };

  evalNixos = configuration: import "${nixpkgs}/nixos" {
    inherit system configuration;
  };

in {
  iso = (evalNixos myisoconfig).config.system.build.isoImage;
}
