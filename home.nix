{pkgs, ...}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      function fish_greeting
         if [ (tput -T xterm cols) -ge 40 ]; and [ (tput -T xterm lines) -ge 18 ]; ${pkgs.yafetch}/bin/yafetch; end
      end
    '';
    plugins = with pkgs.fishPlugins; [
      {
        name = "pure";
        src = pure.src;
      }
      {
        name = "pisces";
        src = pisces.src;
      }
    ];
    shellAliases = {
      "du" = "${pkgs.du-dust}/bin/dust";
      "ls" = "${pkgs.unstable.eza}/bin/eza --icons";
      "la" = "${pkgs.unstable.eza}/bin/eza --icons -la --extended --git";
      "cat" = "${pkgs.bat}/bin/bat";
      "df" = "${pkgs.duf}/bin/duf";
      "ps" = "${pkgs.procs}/bin/procs";
      "curl" = "${pkgs.curlie}/bin/curlie";
      "dig" = "${pkgs.dogdns}/bin/dog";
      "cp" = "${pkgs.xcp}/bin/xcp";
    };
  };
  home.stateVersion = "24.05";
}
