{
  kubenix,
  lib,
  ...
}: let
  makers = (import ./helpers.nix {inherit lib;}).makers;
in {
  imports = [
    kubenix.modules.k8s
    (makers.mkBasicDeployment {
      name = "webapp";
      image = "plan9better/webapp:latest";
      replicas = 2;
      targetPort = 3000;
      ingress-hosts = ["easybaremetal.com" "www.easybaremetal.com"];
    })
  ];
}
