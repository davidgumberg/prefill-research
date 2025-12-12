{
  description = "Bitcoin prefill experimental setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    prefill-sender = {
      url = "path:./prefill-sender";
    };
    
    prefill-receiver = {
      url = "path:./prefill-receiver";
    };
  };

  outputs = { self, nixpkgs, disko, prefill-sender, prefill-receiver, ... }:
  let
    system = "x86_64-linux";
    commonModules = [
      disko.nixosModules.disko
      ./modules/disk-config.nix
      ./modules/hardware-hetzner.nix
      ./modules/bitcoin-core-node.nix
    ];
    commonSpecialArgs = {
      bitcoinBaseConf = ./bitcoin-base.conf;
    };
  in {
    nixosConfigurations = {
      prefill-sender-node = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonSpecialArgs // { 
          bitcoinPackage = prefill-sender.packages.${system}.default;
        };
        modules = commonModules ++ [
          ./prefill-sender/prefill-sender-node.nix
        ];
      };
      
      prefill-receiver-node = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonSpecialArgs // { 
          bitcoinPackage = prefill-receiver.packages.${system}.default;
        };
        modules = commonModules ++ [
          ./prefill-receiver/prefill-receiver-node.nix
        ];
      };
    };
  };
}
