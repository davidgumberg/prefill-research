# this is a bitcoind package, but we can specify the branch as an arg
# inspired by https://github.com/peer-observer/infra-library/blob/master/pkgs/bitcoind/default.nix
{
  stdenv,
  lib,
  # nativeBuildInputs
  pkg-config,
  cmake,
  # buildInputs
  boost,
  libsystemtap,
  libevent,
  capnproto,
  gitURL ? "https://github.com/davidgumberg/bitcoin.git",
  gitBranch,
  gitCommit,
}:

stdenv.mkDerivation rec {
  name = "bitcoind";
  version = "${gitURL}-${gitBranch}-${gitCommit}";

  src = builtins.fetchGit {
    url = gitURL;
    ref = gitBranch;
    rev = gitCommit;
  };

  nativeBuildInputs = [
    pkg-config
    libsystemtap
    capnproto
    cmake
  ];

  buildInputs = [
    boost
    libevent
    libsystemtap
    capnproto
  ];

  cmakeFlags = [
    "-DBUILD_TESTS=OFF"
    "-DBUILD_BENCH=OFF"
    "-DBUILD_FUZZ_BINARY=OFF"
    "-DENABLE_WALLET=OFF"
  ];

  # no tests, faster build :)
  doCheck = false;

  enableParallelBuilding = true;
}
