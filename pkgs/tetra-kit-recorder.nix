{ stdenv, lib, fetchFromGitLab, zlib, ncurses, rapidjson, ... }:

stdenv.mkDerivation rec {
  pname = "tetra-kit-recorder";
  version = "3a18aec77641a0a408a20d417a34c3e122fa8bbe";

  src = fetchFromGitLab {
    owner = "larryth";
    repo = pname;
    rev = version;
    sha256 = "sha256-mlxSWHEK+b0s1COLdXadwilfZtnlBqx/B4dOiDrwx9c=";
  };

  preBuild = "cd recorder";

  installPhase = ''
    mkdir -p $out/bin

    cp ./recorder $out/bin
  '';

  nativeBuildInputs = [
    zlib
    ncurses
    rapidjson
  ];

  enableParallelBuilding = true;
}
