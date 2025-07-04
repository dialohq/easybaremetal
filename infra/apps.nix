{
  packages,
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
      image = "${packages.docker-blog.imageName}:${packages.docker-blog.imageTag}";
      replicas = 2;
      targetPort = 3000;
      ingress-hosts = ["easybaremetal.com" "www.easybaremetal.com"];
    })
  ];
}
