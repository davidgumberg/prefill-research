{ config, pkgs, env, ... }:

{
  networking.hostName = "prefill-receiver";
  
  services.bitcoinNode = {
    enable = true;
    nodeConfig = ./bitcoin.conf;
    extraConfig = ''
        addnode=${env.senderIP}
    '';
  };
}
