{ config, pkgs, ... }:

{
  networking.hostName = "prefill-sender";
  
  services.bitcoinNode = {
    enable = true;
    nodeConfig = ./bitcoin.conf;
  };
}
