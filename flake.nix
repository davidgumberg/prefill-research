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
  in {
    nixosConfigurations = {
      prefill-sender-node = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          bitcoinPackage = prefill-sender.${system}.default;
        };
        modules = [
          disko.nixosModules.disko
          ./modules/disk-config.nix
          ./modules/bitcoin-core-node.nix
          ./prefill-sender/prefill-sender-node.nix
        ];
      };
      
      prefill-receiver-node = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          bitcoinPackage = prefill-receiver.${system}.default;
        };
        modules = [
          disko.nixosModules.disko
          ./modules/disk-config.nix
          ./modules/bitcoin-core-node.nix
          ./prefill-receiver/prefill-receiver-node.nix
        ];
      };
    };
  };
}
