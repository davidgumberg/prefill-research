{ config, lib, pkgs, bitcoinPackage, bitcoinBaseConf, env, ... }:


with lib;

{
  options.services.bitcoinNode = {
    enable = mkEnableOption "Bitcoin Core node";
    
    dataDir = mkOption {
      type = types.str;
      default = "/bitcoin";
    };

    nodeConfig = mkOption {
      type = types.path;
      description = "Path to node-specific bitcoin.conf";
    };

    extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Nix-generated node-specif bitcoin.conf lines. (IP's).";
    };
  };

  config = mkIf config.services.bitcoinNode.enable {
    system.stateVersion = "25.11";
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    environment.systemPackages = with pkgs; [
        vim
        git
    ] ++ [
      bitcoinPackage
    ];

    boot = {
       loader = {
         systemd-boot.enable = true;
         efi.canTouchEfiVariables = true;
       };
       initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "ext4" ];
    };

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "prohibit-password";
    };

    users.users.root.openssh.authorizedKeys.keys = [ env.deploySSHKey ];

    users.users.bitcoin = {
      isSystemUser = true;
      group = "bitcoin";
      home = config.services.bitcoinNode.dataDir;
      createHome = true;
    };
    users.groups.bitcoin = {};

    environment.etc."bitcoin/base.conf" = {
      source = bitcoinBaseConf;
      mode = "0640";
      user = "bitcoin";
      group = "bitcoin";
    };

    # Node-specific config
    environment.etc."bitcoin/node.conf" = {
      mode = "0640";
      user = "bitcoin";
      group = "bitcoin";
      text = ''
        ${builtins.readFile config.services.bitcoinNode.nodeConfig}
        ${config.services.bitcoinNode.extraConfig}
      '';
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
            -conf=/etc/bitcoin/base.conf \
        '';
      };
    };

    networking = {
      firewall.allowedTCPPorts = [ 
        22
        8333
      ];
    };
  };
}
