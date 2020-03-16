# see also: https://nixos.mayflower.consulting/blog/2018/09/11/custom-images/
{ system ? "x86_64-linux", hostName ? "dev" }:
let
  nixpkgs = ../nixpkgs;
  myisoconfig = { ... }: {
    imports = [
      ./lib
      "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
      "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
      (./. + "/${hostName}")
      ./headless/modules/service.openssh.nix
    ];

    config = {
      # networking.hostName = hostName;
      networking.wireless.enable = false;
      isoImage.contents = [ { source = ../.;
                              target = "myconfig"; } ];
    };
  };

  evalNixos = configuration: import "${nixpkgs}/nixos" {
    inherit system configuration;
  };

in {
  iso = (evalNixos myisoconfig).config.system.build.isoImage;
}
