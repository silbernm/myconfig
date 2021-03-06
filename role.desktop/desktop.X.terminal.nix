# Copyright 2017 Maximilian Huber <oss@maximilian-huber.de>
# SPDX-License-Identifier: MIT
{ config, lib, pkgs, ... }:

{
  imports = [
    ./desktop.X.common
    ./service.openssh.nix
    ../nixpkgs/nixos/modules/services/x11/terminal-server.nix
  ];
}
