{lib}: {
  makers = {
    mkBasicDeployment = {
      name,
      image,
      replicas,
      targetPort,
      env ? {},
      ingress-hosts ? [],
    }: {
      kubernetes.resources =
        {
          deployments.${name}.spec = {
            revisionHistoryLimit = 0;
            replicas = replicas;
            selector.matchLabels."app.kubernetes.io/name" = name;
            template.metadata.labels."app.kubernetes.io/name" = name;

            template.spec = let
              envList = lib.mapAttrsToList (name: value: {inherit name value;}) env;
            in {
              imagePullSecrets = [{name = "ghcr-auth";}];
              containers = [
                ({
                    name = name;
                    image = image;
                  }
                  // lib.optionalAttrs (builtins.length envList > 0) {
                    env = envList;
                  })
              ];
            };
          };

          services.${name} = {
            spec = {
              selector."app.kubernetes.io/name" = name;
              ports = [
                {
                  protocol = "TCP";
                  port = 80;
                  targetPort = targetPort;
                }
              ];
            };
          };
        }
        // lib.optionalAttrs (builtins.length ingress-hosts > 0)
        {
          ingresses.${name} = {
            metadata.annotations = {
              "cert-manager.io/cluster-issuer" = "letsencrypt-prod";
            };
            spec = let
              hosts = ingress-hosts;
            in {
              ingressClassName = "traefik";
              rules =
                builtins.map (
                  host: {
                    inherit host;
                    http.paths = [
                      {
                        backend.service = {
                          name = name;
                          port.number = 80;
                        };
                        path = "/";
                        pathType = "Prefix";
                      }
                    ];
                  }
                )
                hosts;
              tls = [
                {
                  inherit hosts;
                  secretName = "tls-${name}";
                }
              ];
            };
          };
        };
    };
  };
}
