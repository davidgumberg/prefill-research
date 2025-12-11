{ config, pkgs, ... }:

{
  networking.hostName = "prefill-sender";
  
  services.bitcoinNode = {
    enable = true;
    configFile = ./bitcoin.conf;
  };
}
