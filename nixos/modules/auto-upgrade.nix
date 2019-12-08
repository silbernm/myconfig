# Copyright 2017 Maximilian Huber <oss@maximilian-huber.de>
# SPDX-License-Identifier: MIT

# See:
# - https://nixos.wiki/wiki/Storage_optimization

{ pkgs, ... }:
{
  config = {

    system.autoUpgrade = {
      enable = true;
      flags = [
        "-I" ("nixpkgs=" + <nixpkgs>)
        "-I" ("nixpkgs-overlays=" + <nixpkgs-overlays>)
        "-I" ("nixos-config=" + <nixos-config>)
        "-I" ("myconfig=" + <myconfig>)
      ];
    };

  };
}