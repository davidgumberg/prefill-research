FROM nixos/nix:latest

RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

RUN nix profile add nixpkgs#vim
RUN nix profile add nixpkgs#nixos-rebuild
