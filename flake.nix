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

      # added this
      ./configuration.nix

      # these are your's
      ./modules/disk-config.nix
      ./modules/hardware-hetzner.nix

      # dropped this, as were using the configuration.nix and services.bitcoind now
      # ./modules/bitcoin-core-node.nix
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
            # setting the custom, per-host package here..
            services.bitcoind."mainnet".package = pkgs.callPackage ./bitcoind.nix {
              gitBranch = "prefill-sender";
              gitCommit = "9ea5096788345015f80aaeb5928a3dfc927e882f";
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
            # setting the custom, per-host package here..
            services.bitcoind."mainnet".package = pkgs.callPackage ./bitcoind.nix {
              gitBranch = "prefill-receiver";
              gitCommit = "c3f16bc3b1eeb1aee5fce5d13d258e4fed858d67";
            };
          }
        ];
      };
    };
  };
}
