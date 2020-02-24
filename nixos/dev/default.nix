{ pkgs, ...}: {
  imports = [
    ../desktop
    # modules
    ./modules/dev.core.nix
    ./modules/dev.haskell
    ./modules/dev.iot.nix
    ./modules/dev.python.nix
    ./modules/dev.network.nix
    ./modules/virtualization.docker
    ./modules/virtualization.qemu.nix
    ./modules/virtualization.vbox
  ];
  config = {
    environment.systemPackages = [
      (pkgs.callPackage ./pkgs/license-compliance-toolbox { inherit pkgs; })
    ];
  };
}
