# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# =======================
# UPDATE: before doing switch, make sure update flake here is proper commands (INSIDE /etc/nixos) AND SUDO
# change flake.nix to be the updated package versions and also in home.nix
# nix flake update
# nixos-rebuild switch --flake .
# =======================

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    #  <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.download-buffer-size = 524288000;

  boot.kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1" "nvidia-drm.modeset=1" "nvidia_drm.fbdev=1"];

  boot.initrd.luks.devices."luks-a03f42b2-888a-48cf-8010-2bca214d5e15".device = "/dev/disk/by-uuid/a03f42b2-888a-48cf-8010-2bca214d5e15";
  networking.hostName = "falaxir-g5-5590"; # Define your hostname
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };

  fonts.packages = with pkgs; [
    roboto
  ];

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Bitwarden ssh agent disable default gnome ssh agent (removed ssh option on list)
  services.gnome.gnome-keyring.enable = true;
  environment.etc."xdg/autostart/gnome-keyring-ssh.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=SSH Key Agent
      Hidden=true
  '';

  # Use computer dns to use computer dns resolver
  networking = {
    nameservers = [ "127.0.0.1" "::1" ];
    # If using dhcpcd:
    dhcpcd.extraConfig = "nohook resolv.conf";
    # If using NetworkManager:
    networkmanager.dns = "none";
    networkmanager.enable = true;
  };

  services.dnscrypt-proxy2 = {
    enable = true;
    # Settings reference:
    # https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml
    settings = {
      ipv6_servers = true;
      require_dnssec = true;
      # Add this to test if dnscrypt-proxy is actually used to resolve DNS requests
      #query_log.file = "/var/log/dnscrypt-proxy/query.log";
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
      # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
      server_names = [ "quad9-dnscrypt-ip4-filter-ecs-pri" "quad9-dnscrypt-ip6-filter-ecs-pri"];
      # Add cloaking rules for local DNS overrides
      cloaking_rules = "/etc/dnscrypt-proxy/cloaking-rules.txt";
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.falaxir = {
    isNormalUser = true;
    description = "Falaxir";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      goofcord
      # mpv
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Virtual machine
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["faxou42"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  environment.pathsToLink = [ "share/thumbnailers" ]; #heic preview

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    gnomeExtensions.brightness-control-using-ddcutil
    gnomeExtensions.status-icons
    gnomeExtensions.system-monitor
    gnomeExtensions.ssh-profile-list
    #gnome-tweaks #has moved to gnome extension
    devenv #Manage dev env
    xpipe
    osu-lazer-bin
    resources #resource monitoring
    spotify    
    syncthing
    libheif #heic preview
    libheif.out #heic preview
    nvtopPackages.nvidia
    vopono #vpn
    wireguard-tools
    libva-utils #for nvidia vaapi
    libva
    mesa
    glxinfo
    ffmpeg-full
    nv-codec-headers #nvidia codec header
    libvdpau-va-gl #nvidia vaapi stuff
    distrobox
    nvidia-container-toolkit
    lm_sensors
    #protonup-qt
    mangohud # game fps counter and stats
    protonplus
    moonlight-qt
    qdiskinfo
    yt-dlp
    traceroute
    dig
    #turbovnc
    #nomachine-client
    #bitwarden-desktop
    python314Full
    #element-desktop
    #wprs
    typst
    git
    zed-editor
    docker-compose
    librewolf
    mpv
    wl-clipboard #For mpv clickboard
    #epson-201106w # SX535WD driver printer # BUILD FAILS
    aegisub
    python312Packages.vpk
    mediainfo
    ncdu #file size analyser accross folders
    teams-for-linux
    smartmontools
    vulkan-tools
    bitwarden-desktop

    #GStreamer packages
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    gst_all_1.gst-vaapi
    #Gstreamer 32bits packages
    pkgsi686Linux.gst_all_1.gstreamer
    pkgsi686Linux.gst_all_1.gst-plugins-base
    pkgsi686Linux.gst_all_1.gst-plugins-good
    pkgsi686Linux.gst_all_1.gst-plugins-bad
    pkgsi686Linux.gst_all_1.gst-plugins-ugly
    pkgsi686Linux.gst_all_1.gst-libav
    pkgsi686Linux.gst_all_1.gst-vaapi
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  environment.localBinInPath = true;

  environment.variables = {
    "XKB_DEFAULT_VARIANT" = "azerty";
    "XKBVARIANT" = "fr";
    "XKBLAYOUT" = "fr";
    "XKB_DEFAULT_LAYOUT" = "fr(azerty)";
    "NIXPKGS_ALLOW_UNFREE" = "1";
    "LIBVA_DRIVER_NAME" = "nvidia";
    "VDPAU_DRIVER" = "nvidia";
    "SSH_AUTH_SOCK" = "/home/falaxir/.bitwarden-ssh-agent.sock";
    # 32 bits Gstreamer
    "GST_PLUGIN_SYSTEM_PATH_1_0_32" = "${pkgs.pkgsi686Linux.gst_all_1.gstreamer.out}/lib/gstreamer-1.0:${pkgs.pkgsi686Linux.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:${pkgs.pkgsi686Linux.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0:${pkgs.pkgsi686Linux.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0:${pkgs.pkgsi686Linux.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0:${pkgs.pkgsi686Linux.gst_all_1.gst-libav}/lib/gstreamer-1.0:${pkgs.pkgsi686Linux.gst_all_1.gst-vaapi}/lib/gstreamer-1.0";
    # 64 bits Gstreamer
    "GST_PLUGIN_SYSTEM_PATH_1_0" = "${pkgs.gst_all_1.gstreamer.out}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-libav}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-vaapi}/lib/gstreamer-1.0";
  };

  #Flapak
  services.flatpak.enable = true;

  #Nix ld for running linix compiled software (Unreal Engine, ...)
  programs.nix-ld.enable = true;

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };


  # Flakes enable
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  #Home manager config without flakes
  #home-manager.users.falaxir = { pkgs, ... }: {
  #  home.packages = [ pkgs.atool pkgs.httpie ];
  #  programs.bash.enable = true;

    # The state version is required and should stay at the version you
    # originally installed.
  #  home.stateVersion = "24.11";
  #  dconf.settings = {
  #    "org/gnome/mutter" = {
  #      experimental-features = [ "scale-monitor-framebuffer" ];
  #    };
  #    "org/gnome/desktop/interface" = {
  #      gtk-enable-primary-paste = false; #Disable middle click paste
  #    };
  #  };
  #};

  #Nvidia settings
  #===============

  # Enable graphics (replaces OpenGL enable)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  hardware.i2c.enable = true;

  programs.obs-studio = {
    enable = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      #obs-vaapi #optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true; 
    package = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        libkrb5
        keyutils
      ];
    };
  };

  programs.gamemode.enable = true; #requires "gamemoderun %command%" to be added to game steam launch param

  # netbird
  services.netbird.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia-container-toolkit.enable = true;

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    #Rollback to 560 because 565 has issues (flatseal not working wayland, lag web browser in 4k)
    #package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #  version = "560.35.03";
    #  sha256_64bit = "sha256-8pMskvrdQ8WyNBvkU/xPc/CtcYXCa7ekP73oGuKfH+M=";
    #  sha256_aarch64 = "sha256-s8ZAVKvRNXpjxRYqM3E5oss5FdqW+tv1qQC2pDjfG+s=";
    #  openSha256 = "sha256-/32Zf0dKrofTmPZ3Ratw4vDM7B+OgpC4p7s+RHUjCrg=";
    #  settingsSha256 = "sha256-kQsvDgnxis9ANFmwIwB7HX5MkIAcpEEAHc8IBOLdXvk=";
    #  persistencedSha256 = "sha256-E2J2wYYyRu7Kc3MMZz/8ZIemcZg68rkzvqEwFAL3fFs=";
    #};

  };
  #Hotspot wifi
  #networking.firewall.allowedTCPPorts = [ 53 ];
  #networking.firewall.allowedUDPPorts = [ 67 53 ];
  #Safer hostpot wifi
  networking.firewall.interfaces."wlo1".allowedTCPPorts = [ 53 ];
  networking.firewall.interfaces."wlo1".allowedUDPPorts = [ 53 67 ];


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
