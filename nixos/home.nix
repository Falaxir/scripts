{ config, pkgs, ... }:

{
  # TODO please change the username & home directory to your own
  home.username = "falaxir";
  home.homeDirectory = "/home/falaxir";

  home.packages = [ pkgs.atool pkgs.httpie pkgs.gnomeExtensions.system-monitor pkgs.gnomeExtensions.status-icons ];
  programs.bash = {
    enable = true;
    #sessionVariables = {
    #  SSH_AUTH_SOCK = "/home/falaxir/.bitwarden-ssh-agent.sock";
    #};

    #initExtra = ''
    #  # include .profile if it exists
    #  [[ -f ~/.profile ]] && . ~/.profile
    #'';
  };

  dconf.settings = {
    # GNOME EXTENSIONS MIGRATED INTO SYSTEM PACKAGES
    #"org/gnome/shell" = {
    #  enabled-extensions = with pkgs.gnomeExtensions; [ #list on nixpackage, filter by gnome extensions
    #      "system-monitor.extensionUuid"
    #  "status-icons.extensionUuid"
    #      "brightness-control-using-ddcutil.extensionUuid"
    #  ];
    #};
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" "variable-refresh-rate" ]; #More display scaling options + vrr
    };
    "org/gnome/desktop/interface" = {
      gtk-enable-primary-paste = false; #Disable middle click paste
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
