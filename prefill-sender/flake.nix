{
  description = "Prefill Sender Setup";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "Bitcoin Core";
        version = "0.0.0.0";

        src = pkgs.fetchFromGitHub {
          owner = "davidgumberg";
          repo = "bitcoin";
          rev = "prefill-sender";
          hash = "sha256-3u/8u9/tLc1XcVx1qjsrKUKZI1x2V1C4ZMXpM4hxejI=";
        };

        nativeBuildInputs = [
            pkgs.cmake
            pkgs.pkg-config
        ];
        buildInputs = [
            pkgs.boost
            pkgs.libevent
            pkgs.sqlite
        ];
        cmakeFlags = [
            "-DBUILD_GUI=OFF"
            "-DBUILD_WALLET=OFF"
            "-DENABLE_IPC=OFF"
        ];
      };
    };
}
