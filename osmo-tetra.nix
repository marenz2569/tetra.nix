{ stdenv, lib, fetchFromGitHub, libosmocore, talloc, ... }:

stdenv.mkDerivation rec {
  pname = "osmo-tetra";
  version = "f730be3e7e426bf4d2b499574f66b26733642c3d";

  src = fetchFromGitHub {
    owner = "sq5bpf";
    repo = "osmo-tetra-sq5bpf";
    rev = version;
    sha256 = "sha256-a5lMrotuRd8rm07TdpEYklCdIICc64HJwB3Kl5PQ4Iw=";
  };

  patches = [ ./tetra-sds.patch ./tetra-location.patch ];

  preBuild = "cd src";

  installPhase = ''
    mkdir -p $out/bin

    cp ./tetra-rx $out/bin/
    cp ./float_to_bits $out/bin/
  '';

  nativeBuildInputs = [
    libosmocore
    talloc
  ];

  NIX_CFLAGS_COMPILE = "-ltalloc";

  enableParallelBuilding = true;
}
