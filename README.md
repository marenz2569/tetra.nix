# tetra.nix

Tetra receiving and reverse engineering tools packaged for NixOS.

## Getting Started

On your journey with tetra you probably want to get started looking for some actual tetra signal.

Currenty two main open source projects are out in the wild.
The first one is [osmo-tetra](https://github.com/osmocom/osmo-tetra) and some forks, especially the one from [sq5bpf](https://github.com/sq5bpf/osmo-tetra-sq5bpf).
The second one is [tetra-kit](https://gitlab.com/larryth/tetra-kit).

To get a tmux session started with all the tools for osmo-tetra run: `nix run github:marenz2569/tetra.nix#osmo-tetra-tmux`.
Analog for tetra-kit: `nix run github:marenz2569/tetra.nix#tetra-kit-tmux`.

I would recommend using the tetra-kit phy receiver and try out both osmo-tetra and tetra-kit for decoding the signal.
If you want to use osmo-tetra decoder with the tetra-kit receiver use the following command: `socat STDIO UDP-LISTEN:42000 | stdbuf -i0 -o0 tetra-rx /dev/stdin` 

## Recording Tetra Signals and Web Frontend for Speech

Import the tetra nixos-module from this flake.

Example Nix configuration:

```
security.acme.acceptTerms = true;
security.acme.defaults.email = "example@example.com";

services.tetra = {
  enable = true;
  centerFrequency = 428000000;
  sampRate = 2000000;
  instances = {
    "tetra1.tetra.example.com".offset = 10000;
    "tetra2.tetra.example.com".offset = 85000;
  };
};
```

Data from tetra-kit will be saved in `/var/lib/tetra-kit/tetra1.tetra.example.com` and `/var/lib/tetra-kit/tetra2.tetra.example.com` respectivly.

## Decoding Speech using a hacked together Jupyter Notebook (not recommended)

There is a speech [decode jupyter notebook](https://github.com/marenz2569/tetra.nix/blob/master/Speech%20Decode.ipynb).
Open the tetra-kit-tmux session. Run `decoder -d 2 | stdbuf -i0 -o0 grep "{\"" | stdbuf -i0 -o0 tee /dev/stderr data`.
Clone this repository and run the jupyter notebook with `nix develop .#speech-decode-notebook`.
