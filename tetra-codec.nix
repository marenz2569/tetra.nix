{ stdenv, lib, fetchFromGitHub, fetchurl, unzip, ... }:

let
  patchSrc = "${fetchFromGitHub {
    owner = "osmocom";
    repo = "osmo-tetra";
    rev = "615146270fbb391c3bae244d181ada645608a7bf";
    sha256 = "sha256-7lhuyUfLV/fzZ0F8UkMKzQMUVY+dwB2m9Zzy8wwo6BI=";
  }}/etsi_codec-patches";
in
stdenv.mkDerivation {
  pname = "tetra-codec";
  version = "01.03.01_60";

  src = fetchurl {
    url = http://www.etsi.org/deliver/etsi_en/300300_300399/30039502/01.03.01_60/en_30039502v010301p0.zip;
    sha256 = "sha256-H+GMR3PIzLUu8jyltKCwhBs41U3dXZx9huuLBg8TLzk=";
  };

  nativeBuildInputs = [ unzip ];
  unpackPhase = "unzip -L $src";

  patches = map (f: "${patchSrc}/" + f) [ "makefile-cleanups.patch" "fix_64bit.patch" "round_private.patch" "filename-case.patch" "log_stderr.patch" ];

  preBuild = "cd c-code";

  installPhase = ''
    mkdir -p $out/bin

    cp ./ccoder $out/bin/
    cp ./cdecoder $out/bin/
    cp ./scoder $out/bin/
    cp ./sdecoder $out/bin/
  '';

  enableParallelBuilding = true;
}
