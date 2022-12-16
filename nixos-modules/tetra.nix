{ pkgs, config, lib, ... }:
let cfg = config.services.tetra;
in {
  options.services.tetra = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Wheather to enable tetra-kit receiver.
      '';
    };
    centerFrequency = mkOption {
      type = types.int;
      default = 0;
      description = ''
        Center frequency of the SDR (default: 0)
      '';
    };
    sampRate = mkOption {
      type = types.int;
      default = 1000000;
      description = "	Sample rate of the sdr (default: 1000000)\n";
    };
    instances = mkOption {
      type = types.attrsOf (types.submodule {
        options.offset = mkOption {
          type = types.int;
          default = 0;
          description = ''
            Offset of the center of the TETRA channel relative to the frequency of the SDR
          '';
        };
      });
      default = { };
      description = ''
        HostName -> { tetraParameters }

        Enable security.acme.acceptTerms = true; for it to work
      '';
    };
  };

  config = let hostNames = lib.attrNames cfg.instances;
  in lib.mkIf cfg.enable {
    hardware.hackrf.enable = lib.mkDefault true;
    hardware.rtl-sdr.enable = lib.mkDefault true;

    services.tetra-receiver = {
      enable = true;
      centerFrequency = cfg.centerFrequency;
      sampRate = cfg.sampRate;
      offsets = lib.mapAttrsToList (name: value: value.offset) cfg.instances;
    };

    services.tetra-kit.enable = true;
    services.tetra-kit.group = config.users.groups.tetra.name;

    services.tetra-kit.instances = builtins.listToAttrs (builtins.genList (i: {
      name = builtins.elemAt hostNames i;
      value = {
        decoderPort = config.services.tetra-receiver.udpStart + i;
        recorderPort = config.services.tetra-receiver.udpStart + i + 1000;
      };
    }) (builtins.length hostNames));

    services.tetra-kit-player.enable = true;
    services.tetra-kit-player.group = config.users.groups.tetra.name;

    services.tetra-kit-player.instances = builtins.listToAttrs (builtins.genList
      (i: {
        name = builtins.elemAt hostNames i;
        value = {
          port = config.services.tetra-receiver.udpStart + i + 2000;
          tetraKitRawPath = "/var/lib/tetra-kit/" + builtins.elemAt hostNames i
            + "/raw/";
          tetraKitLogPath = "/var/lib/tetra-kit/" + builtins.elemAt hostNames i
            + "/log.txt";
        };
      }) (builtins.length hostNames));

    systemd.services = builtins.listToAttrs (builtins.genList (i: {
      name = "tetra-kit-player-${builtins.elemAt hostNames i}";
      value = {
        after = [ "tetra-kit-recorder-${builtins.elemAt hostNames i}.service" ];
      };
    }) (builtins.length hostNames));

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    services.nginx.enable = lib.mkDefault true;
    services.nginx.virtualHosts = builtins.listToAttrs (builtins.genList (i: {
      name = builtins.elemAt hostNames i;
      value = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://127.0.0.1:${
            toString (config.services.tetra-receiver.udpStart + i + 2000)
          }/";
      };
    }) (builtins.length hostNames));

    users.groups.tetra = { };
  };
}
