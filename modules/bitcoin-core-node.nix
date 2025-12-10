# modules/bitcoin-node.nix
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
    # Create bitcoin user
    users.users.bitcoin = {
      isSystemUser = true;
      group = "bitcoin";
      home = config.services.bitcoinNode.dataDir;
      createHome = true;
    };
    users.groups.bitcoin = {};

    # Deploy the config file
    environment.etc."bitcoin/bitcoin.conf" = {
      source = config.services.bitcoinNode.configFile;
      mode = "0640";
      user = "bitcoin";
      group = "bitcoin";
    };

    # Systemd service
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
      8333
    ];
  };
}
