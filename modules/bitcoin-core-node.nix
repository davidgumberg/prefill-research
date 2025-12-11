{ config, lib, pkgs, bitcoinPackage, ... }:

with lib;

{
  options.services.bitcoinNode = {
    enable = mkEnableOption "Bitcoin Core node";
    
    configFile = mkOption {
      type = types.path;
      description = "Path to bitcoin.conf";
    };
    
    dataDir = mkOption {
      type = types.str;
      default = "/bitcoin";
    };
  };

  config = mkIf config.services.bitcoinNode.enable {
    system.stateVersion = "25.11";

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "prohibit-password";
    };

    users.users.root.openssh.authorizedKeys.keys = [
      # OMITTED
    ];

    users.users.bitcoin = {
      isSystemUser = true;
      group = "bitcoin";
      home = config.services.bitcoinNode.dataDir;
      createHome = true;
    };
    users.groups.bitcoin = {};

    environment.etc."bitcoin/bitcoin.conf" = {
      source = config.services.bitcoinNode.configFile;
      mode = "0640";
      user = "bitcoin";
      group = "bitcoin";
    };

    systemd.services.bitcoind = {
      description = "Bitcoin daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "simple";
        User = "bitcoin";
        Group = "bitcoin";
        ExecStart = ''
          ${bitcoinPackage}/bin/bitcoind \
            -datadir=${config.services.bitcoinNode.dataDir} \
            -conf=/etc/bitcoin/bitcoin.conf \
        '';
      };
    };

    networking.firewall.allowedTCPPorts = [ 
      22
      8333
    ];
  };
}
