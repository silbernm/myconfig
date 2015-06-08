{ config, pkgs, ... }:

let
  hsPackages = with pkgs.haskellPackages; [
    xmonad xmobar
    ghc hlint cabalInstall pandoc pointfree pointful hdevtools cabal2nix
  ];
  myPackages = with pkgs; [
    wget curl elinks w3m
    htop powertop
    vim

# for development
    leiningen clojure

# Virtualization
    # virtualbox
    # docker

# For email setup
    tmux-with-sidebar
    offlineimap
    msmtp
    gnupg
    abook

# git
    # gitAndTools.gitFull
    # git
    gitMinimal

# for the desktop environmen
    xlibs.xmodmap
    xlibs.xset
    dmenu
    scrot
    unclutter
    feh
    redshift
    rxvt_unicode_with-plugins
    roxterm
    chromium
    ] ++ hsPackages;
###############################################################################
in {
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  networking = {
    hostName = "nixos"; # Define your hostname.
    hostId = "54510fe1"; # TODO: ?
    # wireless.enable = true;  # Enables wireless.
  };

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "de";
    defaultLocale = "de_DE.UTF-8";
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment = {
    systemPackages = myPackages;
    # shellAliases = {
    #   ll = "ls -l";
    # };
    shells = ["/run/current-system/sw/bin/zsh"];
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
      corefonts
      inconsolata
    ];
  };

  powerManagement.enable = true;

  time.timeZone = "Europe/Berlin";

  services = {
    openssh.enable = true;
    printing.enable = true;
    xserver = {
      enable = true;
      autorun = false;
      layout = "de"; # TODO: neo
      # xkbOptions = "eurosign:e";
      windowManager = {
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
        };
        default = "xmonad";
      };
      desktopManager.default = "none";
      displayManager.sessionCommands = ''
        ${pkgs.xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr &
        ${pkgs.redshift}/bin/redshift -l 48.2:10.8 &
        ${pkgs.roxterm}/bin/roxterm &
      '';

      startGnuPGAgent = true;

      # synaptics.additionalOptions = ''
      #   Option "VertScrollDelta" "-100"
      #   Option "HorizScrollDelta" "-100"
      #   '';
      # synaptics.buttonsMap = [ 1 3 2 ];
      # synaptics.enable = true;
      # synaptics.tapButtons = false;
      # synaptics.fingersMap = [ 0 0 0 ];
      # synaptics.twoFingerScroll = true;
      # synaptics.vertEdgeScroll = false;
    };

    nixosManual.showManual = true;
  };

  users = {
    extraUsers.mhuber = {
      isNormalUser = true;
      group = "users";
      uid = 1000;
      extraGroups = [ "wheel" ];
      createHome = true;
      home = "/home/mhuber";
      shell = "/run/current-system/sw/bin/zsh";
    };
    extraGroups.docker.members = [ "mhuber" ];
  };
  virtualisation.docker.enable = true;
  programs.zsh.enable = true;
}

# vim:set ts=2 sw=2 sts=2 et foldmethod=marker foldlevel=0 foldmarker={{{,}}}: