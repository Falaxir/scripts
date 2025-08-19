{ mkNixPak, pkgs }:

mkNixPak {
  config = { sloth, ... }: {
    bubblewrap = {
      bind.ro = [ 
        (sloth.concat' sloth.homeDir "Documents")
        (sloth.concat' sloth.homeDir ".wine") 
      ];
      network = false;
      bind.dev = [
        "/dev/dri"
      ];
    };
    app = {
      package = pkgs.wineWowPackages.waylandFull;
      binPath = "bin/wine";

      # list of executables to wrap in addition to the default /bin/vim
      extraEntrypoints = [
        "/bin/winetricks"
      ];
    };
  };
}

