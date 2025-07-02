## Preface

Note that we don't expect you to understand exactly how this all works at first, but the example Flake in this tutorial is made in a way that you can just copy it and use it in your projects with minimal changes. Once you start using it, asking LLMs or Googling how to make it do exactly what you want is the best way to learn Nix.

If you haven’t already enabled Flakes, add the following line to your `/etc/nix/nix.conf` or `~/.config/nix/nix.conf`:

```conf
experimental-features = nix-command flakes

```

## What Are They

Flakes are technically an *experimental* feature, but the community adopted them as the default way to configure stuff with Nix because of a few advantages over the legacy *channels*.

The big two advantages are:

### A `flake.lock` File

A typical lock file ensures that the version of a particular package is always the same until you change it explicitly. Nothing too exciting here, you never have to look at it. Just remember to commit it to Git to have the same versions whenever you pull the repo on a different machine.

```json
"nixpkgs": {
  "locked": {
    "lastModified": 1686488075,
    "narHash": "sha256-2otSBt2hbeD+5yY25NF3RhWx7l5SDt1aeU3cJ/9My4M=",
    "owner": "NixOS",
    "repo": "nixpkgs",
    "rev": "9401a0c780b49faf6c28adf55764f230301d0dce",
    "type": "github"
  },
  "original": {
    "owner": "NixOS",
    "ref": "nixpkgs-unstable",
    "repo": "nixpkgs",
    "type": "github"
  }
},
````

### All Dependencies Are Explicit

Everything you use is declared upfront in a section called `inputs`, and its version is locked in `flake.lock`.

```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/81bbc0eb0b178d014b95fc769f514bedb26a6127";
  flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b";
  kubenix.url = "github:hall/kubenix";
};
```

Here, we pointed the inputs at a specific commit in the nixpkgs GitHub repo by its hash, but you can also just use a branch name like `nixpkgs-unstable`. While this may look similar to legacy channels, flakes actually reference Git branches or commits directly.

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
};
```

In this example, we pin it to the unstable branch, which has the most and latest packages.

## Full Example

The most common place you'll see Flakes is in development environments. It's one of the best use cases for Nix, ensuring everyone working on the project has the exact same dev environment, eliminating the "it works on my machine" problem.

```nix
{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            pnpm_9
          ];
          shellHook = ''
            pnpm --version
          '';
          env = {
            EDITOR = "nvim";
          };
        };
      }
    );
}
```

We'll go through this example line by line in a second, but I encourage you to copy and paste it on your local machine and run `nix develop`.

(If you put it in a Git repo, you'll see an error saying it's not tracked by Git. This is to prevent unwanted unversioned changes. Either add it to Git with `git add`, or move it out of the Git repo. You don't have to commit it, adding it is enough.)

You should see something like:

```
warning: Git tree '/Users/patrykwojnarowski/dev/easybaremetal' is dirty
warning: creating lock file '"/Users/patrykwojnarowski/dev/easybaremetal/tutorials/flake.lock"':
• Added input 'flake-utils':
    ...
9.15.9
(nix:nix-shell-env) bash-5.2$
```

You can ignore the Git warnings, it just says that the current version of the Flake is not committed.

The other lines indicate that Nix fetched the latest versions of the specified inputs (e.g., `nixpkgs`, `flake-utils`) from GitHub. At the end, just above the prompt, you should see the version of `pnpm` Nix installed and exposed to you.

## Line by Line (More or Less)

The entire thing is enclosed in a set of `{}`. You can think of Nix as a programming language that evaluates to something like a JSON object (called an *attribute set* in Nix).

First, we define the `inputs`:

```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  flake-utils.url = "github:numtide/flake-utils";
};
```

These tell Nix what repositories to fetch and use later in the Flake.

So far, Nix might just seem like slightly different way to write JSON and not a programming language, where are the functions and variables?

Right here

Next is the `outputs` function:

```nix
outputs = { nixpkgs, flake-utils, ... }: { ... }
```

This defines a function named `outputs` that takes a set of inputs (`nixpkgs`, `flake-utils`, and others via `...`) and returns another attribute set. Nix will evaluate this function and extract specific attributes depending on the context, for example, when running `nix develop`, it looks for a `devShells` attribute.

Instead of directly returning a value, we pass a function into a helper:

```nix
flake-utils.lib.eachDefaultSystem (
  system: let
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        pnpm_9
      ];
      shellHook = ''
        pnpm --version
      '';
      env = {
        EDITOR = "hx";
      };
    };
  }
)
```

### What’s Going On Here?

* `eachDefaultSystem` is a helper from `flake-utils` that runs your function for each common platform Nix supports:

  * `x86_64-linux`
  * `aarch64-linux`
  * `x86_64-darwin`
  * `aarch64-darwin`

This way, one Flake can work across all major platforms. The `system` argument passed to your function is a string like `"x86_64-linux"`.

We use it like this:

```nix
pkgs = import nixpkgs {
  inherit system;
  config.allowUnfree = true;
};
```

This imports the `nixpkgs` input for the specific platform and allows the use of unfree packages (e.g., proprietary software).

Next, we define our actual development shell:

```nix
devShells.default = pkgs.mkShell {
  packages = with pkgs; [
    pnpm_9
  ];
  shellHook = ''
    pnpm --version
  '';
  env = {
    EDITOR = "hx";
  };
};
```

Here's what each part does:

* `packages` is a list of packages available in the shell. We use `with pkgs;` so we don't have to write `pkgs.pnpm_9`.

  Equivalent version:

  ```nix
  packages = [
    pkgs.pnpm_9
  ];
  ```

* `shellHook` is a shell script that runs when you enter the environment.

* `env` lets you set environment variables in the shell. Avoid putting secrets here, as the contents of the flake and anything added to Git is copied into the `/nix/store` in plain text.

  For secrets, a common pattern is to use a `.env` file (ignored by Git) and load it in your `shellHook`:

  ```nix
  shellHook = ''
    source .env
    pnpm --version
  '';
  ```

And that's it!
