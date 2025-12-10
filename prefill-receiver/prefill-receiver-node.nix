{ config, pkgs, ... }:

{
  networking.hostName = "prefill-receiver";
  
  services.bitcoinNode = {
    enable = true;
    configFile = ./bitcoin.conf;
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHN+Hrhk5MhyH1sGc81VkMJwM7W9M2YcNOmWR3rM4lqKAAAABHNzaDo="
  ];
}
