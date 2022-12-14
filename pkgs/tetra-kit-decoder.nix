{ stdenv, lib, fetchFromGitLab, zlib, rapidjson, ... }:

stdenv.mkDerivation rec {
  pname = "tetra-kit-decoder";
  version = "3a18aec77641a0a408a20d417a34c3e122fa8bbe";

  src = fetchFromGitLab {
    owner = "larryth";
    repo = pname;
    rev = version;
    sha256 = "sha256-mlxSWHEK+b0s1COLdXadwilfZtnlBqx/B4dOiDrwx9c=";
  };

  preBuild = "cd decoder";

  installPhase = ''
    mkdir -p $out/bin

    cp ./decoder $out/bin
  '';

  nativeBuildInputs = [
    zlib
    rapidjson
  ];

  enableParallelBuilding = true;
}
