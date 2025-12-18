FROM nixos/nix:latest

RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# Don't even ask
RUN git config --global --add safe.directory /workspace

RUN nix profile add nixpkgs#vim
RUN nix profile add nixpkgs#nixos-rebuild

WORKDIR /workspace
