{kubenix, ...} @ args: {
  imports = with kubenix.modules; [k8s helm];
  kubernetes.resources = {
    namespaces.cert-manager = {};
  };
  kubernetes.helm.releases.cert-manager = {
    namespace = "cert-manager";
    overrideNamespace = true;
    chart = kubenix.lib.helm.fetch {
      repo = "https://charts.jetstack.io";
      chart = "cert-manager";
      version = "1.18.0";
      sha256 = "sha256-FlBah+0vr+9OBEAv/xQkCqjItGwG8QYOXh461OMDGB0=";
    };
    values = {
      crds.enabled = true;
      global.leaderElection.namespace = "cert-manager";
    };
  };
}
