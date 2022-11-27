{ stdenv, lib, fetchFromGitHub, libosmocore, talloc, ... }:

stdenv.mkDerivation rec {
  pname = "osmo-tetra";
  version = "615146270fbb391c3bae244d181ada645608a7bf";

  src = fetchFromGitHub {
    owner = "osmocom";
    repo = "osmo-tetra";
    rev = version;
    sha256 = "sha256-7lhuyUfLV/fzZ0F8UkMKzQMUVY+dwB2m9Zzy8wwo6BI=";
  };

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
