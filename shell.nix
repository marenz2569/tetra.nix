{ pkgs, osmo-tetra }:
let
  custom_gnuradio = pkgs.gnuradio3_7.override {
    extraPackages = with pkgs.gnuradio3_7Packages; [ osmosdr ];
  };

  telive = pkgs.fetchFromGitHub {
    owner = "sq5bpf";
    repo = "telive";
    rev = "44304af1d516275690b41a77031e961412ece95e";
    sha256 = "sha256-9X6dZFS9QMVr0t0PVjgCTwuxe1KvwsK3LyLC5oLWT8I=";
  };
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    bashInteractive
    tmux
    custom_gnuradio
    custom_gnuradio.pythonEnv
    socat
    osmo-tetra
  ];

  shellHook = ''
    session="tetra-rx"

    tmux new-session -d -s $session

    window=1
    tmux rename-window -t $session:$window 'receiver'
    tmux send-keys -t $session:$window 'gnuradio-companion ${telive}/gnuradio-companion/receiver_udp/telive_1ch_simple_gr37_udp.grc'

    window=2
    tmux new-window -t $session:$window -n 'decoder'
    tmux send-keys -t $session:$window 'socat STDIO UDP-LISTEN:42001 | ${osmo-tetra.src}/src/demod/python-3.7/simdemod2.py -o /dev/stdout -i /dev/stdin | float_to_bits /dev/stdin /dev/stdout | tetra-rx /dev/stdin'

    tmux attach-session -t $session
  '';
}
