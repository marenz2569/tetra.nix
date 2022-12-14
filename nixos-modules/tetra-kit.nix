{ pkgs, config, lib, ... }:
let
  cfg = config.services.tetra-kit;
  home = "/var/lib/tetra-kit";
in {
  options.services.tetra-kit = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Wheather to enable tetra-kit receiver.
      '';
    };
    user = mkOption {
      type = types.str;
      default = "tetra-kit";
      description = "	systemd user\n";
    };
    group = mkOption {
      type = types.str;
      default = "tetra-kit";
      description = "	group of systemd user\n";
    };
    instances = mkOption {
      type = types.attrsOf (types.submodule {
        options.decoderPort = mkOption {
          type = types.port;
          default = 42000;
          description = ''
            Port where the decoder receives its bits on.
          '';
        };
        options.recorderPort = mkOption {
          type = types.port;
          default = 42100;
          description = ''
            Port which is used between decoder and recorder for data exchange.
          '';
        };
        options.extraDecoderArgs = mkOption {
          type = types.str;
          default = "";
          description = ''
            Extra arguments for tetra-kit decoder
          '';
        };
        options.extraRecorderArgs = mkOption {
          type = types.str;
          default = "";
          description = ''
            Extra arguments for tetra-kit recorder
          '';
        };
      });
      default = { };
      description = ''
        Instances with names of the tetra-kit receiver.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = lib.concatMapAttrs (instanceName: instanceConfig: {
      "tetra-kit-decoder-${instanceName}" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        script = ''
          exec ${pkgs.tetra-kit-decoder}/bin/decoder -r ${
            toString instanceConfig.decoderPort
          } -t ${
            toString instanceConfig.recorderPort
          } ${instanceConfig.extraDecoderArgs} &
        '';

        serviceConfig = {
          Type = "forking";
          User = cfg.user;
          Restart = "always";
        };
      };

      "setup-tetra-kit-recorder-${instanceName}" = {
        wantedBy = [ "multi-user.target" ];
        script = ''
          mkdir -p ${home}/${instanceName}
        '';

        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
        };
      };

      "tetra-kit-recorder-${instanceName}" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        after = [ "setup-tetra-kit-recorder-${instanceName}.service" ];

        script = ''
          exec ${pkgs.tetra-kit-recorder}/bin/recorder -r ${
            toString instanceConfig.decoderPort
          } ${instanceConfig.extraRecorderArgs} &
        '';

        serviceConfig = {
          Type = "forking";
          User = cfg.user;
          WorkingDirectory = "${home}/${instanceName}";
          Restart = "always";
        };
      };
    });

    # user accounts for systemd units
    users.users."${cfg.user}" = {
      inherit home;
      name = "${cfg.user}";
      description = "This users runs tetra-kit decoder and recorder";
      isNormalUser = false;
      isSystemUser = true;
      createHome = true;
      group = cfg.group;
    };
  };
}
