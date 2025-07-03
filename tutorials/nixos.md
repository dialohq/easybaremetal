## Install on hetzner

To install NixOS on hetzner, first get any cloud server. I recommend the arm64 instances since they are typically cheaper and arm64 support on NixOS is great.
Then:
1. Go to the `ISO images` tab  and mount the NixOS arm64/minimal image.
2. Reboot the machine
3. Open the web console `>_`
4. Follow (these)[https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual] steps.
5. When you get to the `Partitioning and formatting` section, if you wen't with arm64 follow the `UEFI` isntructions and if you chose amd64, `MBR`

## Post-install setup

First thing we'll do is change the configuration.nix to the modern flake, to get all of the benefits discussed above but for our entire system.

Without comments and blank lines your minimal config should look similiar to this:
```nix
{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];
  users.users.spike = {
    isNormalUser = true;
    home = "/home/spike";
    description = "Spike Spiegel";
    extraGroups = ["wheel" "networkmanager"];
    openssh.authorizedKeys.keys = [ "..." ];
  };
  environment.systemPackages = with pkgs; [
    neovim
  ];
  services.openssh.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  system.stateVersion = "25.05";
}
```
> Make sure you don't modify `hardware-configuration.nix` and include it in your final configuration, it's some hardware specific chages automatically picked up by nixos, specific to that machine.

* First thing you have to do is create a `flake.nix` file in the same directory as `configuration.nix` (/etc/nixos/).

> I recommend to run `$ sudo -i` if you're not already root, you won't have to type `sudo` before every command.

```bash
$ touch /etc/nixos/configuration.nix
```

* Next step is to enable flakes in your current configuration since they are still considered `experimental` even though they are the preferred and almost exclusively used by the community way to use nix. Add the following lines to your current `configuration.nix`:

```nix
...
nix.settings.experimental-features = [ "nix-command" "flakes" ];
...
```
and switch to the new configuration:
```bash
$ nixos-rebuild switch
```

* Now that we are ready to use flakes, time to migrate the existing config. Remember this flake is the same as the one we used in the `devShell` tutorial, nix just cares about different attributes found in the `outputs` attribute set, namely the `nixosConfigurations` attribute set.

>  The following example is taken from the (NixOS & flakes book)[https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled] which is a great resource for learning nix and nixos.

```nix
{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    # Please replace my-nixos with your hostname
    nixosConfigurations.my-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix
      ];
    };
  };
}
```
> When copying make sure to replace the `my-nixos` attribute of `nixosConfigurations` with your machines hostname. If you're not sure what it is you can run `$ hostname` to find out. As well as the system, if you're not sure about this one as well check out the output of `$ uname -a`, look for `aarch64` or `x86_64`

Now when you run `$ nixos-rebuild switch` nothing should change, because we just switched to a different way of defining the same options.

> If you would like, you can change the name of your configuration to something other than your hostname, and pass it to the rebuild command explicitly `nixos-rebuild switch --flake /etc/nixos#notYourHostname`. It's the same as with `nix build` and `nix develop`, nix will evaluate the flake, and because it was run with the rebuild switch command it will look for `nixosConfigurations`, and if no more arguments are passed it will look for the configuration named after the hostname, but you can be explicit and change it to whatever you feel like.

Even though the configuration is only imported from the `configuration.nix`, we are still getting the benefits of using flakes.

## Enabling k3s
K3s is a simplified kubernetes distribution that sets up a few things out of the box and is pretty light weight.

To keep our config organized lets create a new file in the same directory as `flake.nix` (still /etc/nixos/) called `k3s.nix` that will contain our configuration.

```nix
{
  services.k3s.enable = true;
}
```
> Yes it's that simple

Now we just need to point to it in our configuration modules
```nix
nixosConfigurations.my-nixos = nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  modules = [
    ./configuration.nix
    ./k3s.nix
  ];
};
```

> Sidenote
> Whenever we import a file in `modules`, it get's called as a function. To see this check out the first line of `configuration.nix`
> `{config, lib, pkgs, ...}: {...}` as you can see it takes a few arguments and returns an attribute set, if we wanted to we could take those same arguments in `k3s.nix` but we don't need them for anything so we just ignore anything passed to this function and always return the same attribute set, our current `k3s.nix` is similiar in spirit to this examle JS function:
> ```js
> function k3s(...args) {
>   return { a: 1, b: 2, c: 3 };
> }
> ```

Now after running `nixos-rebuild switch` we'll have k3s installed and ready to go. 
To test it out you could install `kubectl` (kubernetes management tool) with `$ nix shell nixpkgs#kubectl`, and set an environment variable `KUBECONFIG` to point to `/etc/rancher/k3s/k3s.yaml` with a simple `export KUBECONFIG=/etc/rancher/k3s/k3s.yaml`, which is just a yaml file that lets `kubectl` access the cluster. And run `kubectl get namespaces` to see what's going on.

You should see something similiar to this:
```
NAME              STATUS   AGE
default           Active   10d
kube-node-lease   Active   10d
kube-public       Active   10d
kube-system       Active   10d  
```

> Of course the age will probably be closer to `1m` than `10d`.

Now you're ready to start deploying applications.
