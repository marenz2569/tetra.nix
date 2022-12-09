{ pkgs, tetra-codec }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    tetra-codec
    sox
    (python3.withPackages(ps: with ps; [ numpy ipython jupyter seaborn pandas numpy matplotlib ]))
  ];

  shellHook = ''
    jupyter-notebook
  '';
}
