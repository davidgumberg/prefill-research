{ pkgs
, lib
, config
, env
# this is going to be addnode=${env.senderIP} on the receiver node
, extraExtraConfig ? null
, ...
}:

{
  # naming this mainnet, but could be anything
  # restart it with: systemctl restart bitcoind-mainnet
  services.bitcoind."mainnet" = {
    enable = true;
    # By default, if we don't set a custom package here, its going to use the Bitcoin Core from nixpkgs.
    # https://search.nixos.org/packages?channel=25.11&show=bitcoind&query=bitcoind
    # but this is set on a per-node basis in flake.nix
    # package = ...
    prune = 550;
    dbCache = 4500;
    extraConfig = ''
      datadir=/bitcoin
      logtimemicros=1

      debug=net
      debug=bench
      debug=cmpctblock

      ${
        lib.optionalString (extraExtraConfig != null) ''
          ${extraExtraConfig}
        ''
      }
    '';
  };

  networking = {
    # don't need to open 22, as services.openssh.enable = true; already does that. See below.
    firewall.allowedTCPPorts = [ 8333 ];
  };

  environment.systemPackages = [
    pkgs.vim
    pkgs.git
    # we also want the package here, so we can interact with the bitcoind via bitcoin-cli
    (config.services.bitcoind.mainnet.package)
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

  system.stateVersion = "25.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
