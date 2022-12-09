# tetra.nix

Tetra receiving and reverse engineering tools packaged for NixOS.

## Getting started

On your journey with tetra you probably want to get started looking for some actual tetra signal.

Currenty two main open source projects are out in the wild.
The first one is [osmo-tetra](https://github.com/osmocom/osmo-tetra) and some forks, especially the one from [sq5bpf](https://github.com/sq5bpf/osmo-tetra-sq5bpf).
The second one is [tetra-kit](https://gitlab.com/larryth/tetra-kit).

To get a tmux session started with all the tools for osmo-tetra run: `nix run github:marenz2569/tetra.nix#osmo-tetra-tmux`.
Analog for tetra-kit: `nix run github:marenz2569/tetra.nix#tetra-kit-tmux`.

## Decoding Speech

There is a speech [decode jupyter notebook](./Speech Decode.ipynb).
Open the tetra-kit-tmux session. Run `decoder -d 2 | stdbuf -i0 -o0 grep "{\"" | stdbuf -i0 -o0 tee /dev/stderr data`.
Run the jupyter notebook with `nix develop github:marenz2569/tetra.nix#speech-decode-notebook`.
