#prefill-receiver/prefill-receiver-node.nix
{ config, pkgs, ... }:

{
  networking.hostName = "prefill-receiver";
  
  services.bitcoinNode = {
    enable = true;
    configFile = ./bitcoin.conf;
  };
}
