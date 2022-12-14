{ pkgs, tetra-kit-recorder, tetra-kit-decoder, shellHook ? false }:
let
  custom_gnuradio = pkgs.gnuradio3_8.override {
    extraPackages = with pkgs.gnuradio3_8Packages; [ osmosdr ];
  };
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    bashInteractive
    tmux
    # gnuradio version 3.8
    custom_gnuradio
    tetra-kit-recorder
    tetra-kit-decoder
  ];

  shellHook = pkgs.lib.optionalString shellHook ''
    session="tetra-kit"

    tmux new-session -d -s $session

    window=2
    tmux new-window -t $session:$window -n 'receiver'
    tmux send-keys -t $session:$window 'gnuradio-companion ${tetra-kit-decoder.src}/phy/gnuradio-3.8/pi4dqpsk_rx.grc'

    window=3
    tmux new-window -t $session:$window -n 'decoder'
    tmux send-keys -t $session:$window 'decoder -d 2'

    tmux attach-session -t $session
  '';
}
