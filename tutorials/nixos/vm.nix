{
  virtualisation.vmVariant = {
    virtualisation.graphics = false;
    users.users.spike = {
      isNormalUser = true;
      home = "/home/spike";
      description = "Spike Spiegel";
      extraGroups = ["wheel" "networkmanager"];
      password = "password";
    };
  };
}
