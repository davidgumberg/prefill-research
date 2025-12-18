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
        pname = "prefill-sender";
        version = "0.0.0.0";

        src = pkgs.fetchFromGitHub {
          owner = "davidgumberg";
          repo = "bitcoin";
          rev = "prefill-sender";
          hash = "sha256-n55efD4A/f2th099a43F0NGuc/Pp9Hp/hDL5CZXMlrs=";
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
            "-DBUILD_TESTS=OFF"
            "-DBUILD_WALLET=OFF"
            "-DENABLE_IPC=OFF"
        ];
      };
    };
}
