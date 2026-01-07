{
  description = "Bitcoin prefill experimental setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, ... }:
  let
    system = "x86_64-linux";
    env = import ./env.nix;
    commonModules = [
      disko.nixosModules.disko
      ./configuration.nix
      ./modules/disk-config.nix
      ./modules/hardware-hetzner.nix
    ];
    commonSpecialArgs = { inherit env; };
    pkgs = import nixpkgs { inherit system; };
  in {
    nixosConfigurations = {
      prefill-sender-node = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonSpecialArgs // {
          extraExtraConfig = ''
            # no extra config for the sender node
          '';
        };
        modules = commonModules ++ [
          {
            networking.hostName = "prefill-sender";
            services.bitcoind."mainnet".package = pkgs.callPackage ./bitcoind.nix {
              gitBranch = "prefill-sender";
              gitCommit = "bb154d35e298c328dcaf3e5e62ebf342355e64c9";
            };

          }
        ];
      };
      prefill-receiver-node = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonSpecialArgs // {
          extraExtraConfig = ''
            addnode=${env.senderIP}
          '';
        };
        modules = commonModules ++ [
          {
            networking.hostName = "prefill-receiver";
            services.bitcoind."mainnet".package = pkgs.callPackage ./bitcoind.nix {
              gitBranch = "prefill-receiver";
              gitCommit = "00c1e0754b1d3024064cce253b52822a49600e9f";
            };
          }
        ];
      };
    };
  };
}
