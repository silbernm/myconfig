# Copyright 2018 Maximilian Huber <oss@maximilian-huber.de>
# SPDX-License-Identifier: MIT
{ pkgs ? import <nixpkgs> { }, stdenv ? pkgs.stdenv, mkDerivation, base
, containers, process, X11, xmonad, xmonad-contrib, callPackage, my-xmobar
, my-mute-telco }:
let
  version = "1.0";
  my-xmonad-scripts = ./bin;
  my-xmonad-share = ./share;
  find-cursor = callPackage ./find-cursor.nix { inherit pkgs; };
in mkDerivation {
  inherit version;
  pname = "my-xmonad";
  src = builtins.filterSource (path: type:
    let basename = baseNameOf path;
    in if type == "directory" then
      (basename != ".stack-work" && basename != "dist" && basename != "bin"
        && basename != "share")
    else if type == "symlink" then
      builtins.match "^result(|-.*)$" basename == null
    else
      (builtins.match "^((|..*).(sw[a-z]|hi|o)|.*~)$" basename == null
        && builtins.match ".sh$" basename == null)) ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [ base containers process X11 xmonad xmonad-contrib ];
  executableHaskellDepends = [ base containers X11 xmonad xmonad-contrib ];

  patchPhase = ''
    set -e
    variablesFile=lib/XMonad/MyConfig/Variables.hs

    addAbsoluteBinaryPath() {
      old=$1
      new=$2/bin/$1
      sed -i -e 's%"'$old'%"'$new'%g' $variablesFile
    }

    replaceConfigValue() {
      key=$1
      value=$2
      sed -i -e '/'"$key"' *=/ s%= .*%= "'"$value"'";%' $variablesFile
    }

    addAbsoluteBinaryPath urxvtc ${pkgs.rxvt_unicode-with-plugins}
    addAbsoluteBinaryPath urxvtd ${pkgs.rxvt_unicode-with-plugins}
    addAbsoluteBinaryPath dmenu_path ${pkgs.dmenu}
    addAbsoluteBinaryPath yeganesh ${pkgs.haskellPackages.yeganesh}
    addAbsoluteBinaryPath passmenu ${pkgs.pass}
    addAbsoluteBinaryPath find-cursor ${find-cursor}
    addAbsoluteBinaryPath xdotool ${pkgs.xdotool}
    addAbsoluteBinaryPath synclient ${pkgs.xorg.xf86inputsynaptics}
    addAbsoluteBinaryPath xrandr-invert-colors ${pkgs.xrandr-invert-colors}
    addAbsoluteBinaryPath autorandr ${pkgs.autorandr}
    addAbsoluteBinaryPath feh ${pkgs.feh}
    addAbsoluteBinaryPath unclutter ${pkgs.unclutter}
    addAbsoluteBinaryPath htop ${pkgs.htop}
    addAbsoluteBinaryPath pavucontrol ${pkgs.pavucontrol}
    addAbsoluteBinaryPath light ${pkgs.light}
    addAbsoluteBinaryPath mute_telco ${my-mute-telco}

    replaceConfigValue xmobarCMD "${my-xmobar}/bin/xmobarXmonad"
    replaceConfigValue pathToXmonadBins "${my-xmonad-scripts}/"
    replaceConfigValue pathToXmonadShare "${my-xmonad-share}/"
  '';

  description = "my xmonad configuration";
  license = stdenv.lib.licenses.mit;
}
