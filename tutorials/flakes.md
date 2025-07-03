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
            nodejs_24
          ];
          shellHook = ''
            node --version
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

The other lines indicate that Nix fetched the latest versions of the specified inputs (e.g., `nixpkgs`, `flake-utils`) from GitHub. At the end, just above the prompt, you should see the version of `node` Nix installed and exposed to you.

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
        nodejs_24
      ];
      shellHook = ''
        node --version
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
    nodejs_24
  ];
  shellHook = ''
    node --version
  '';
  env = {
    EDITOR = "hx";
  };
};
```

Here's what each part does:

* `packages` is a list of packages available in the shell. We use `with pkgs;` so we don't have to write `pkgs.nodejs_24`.

  Equivalent version:

  ```nix
  packages = [
    pkgs.nodejs_24
  ];
  ```

* `shellHook` is a shell script that runs when you enter the environment.

* `env` lets you set environment variables in the shell. Avoid putting secrets here, as the contents of the flake and anything added to Git is copied into the `/nix/store` in plain text.

  For secrets, a common pattern is to use a `.env` file (ignored by Git) and load it in your `shellHook`:

  ```nix
  shellHook = ''
    source .env
    node --version
  '';
  ```

And that's it!

One more thing flakes are useful for is building projects, lets build a nodejs app to test it out.

Since we already have `node`, `npm` and `npx` (npm and npx come bundled with node) in the dev shell, we can leave it as is. (Remember, if you're not sure what's the name of the package remember you can use `search.nixos.org`)

```nix
packages = with pkgs; [
  nodejs_24
];
  
```

So we can run the typical `npx create-react-app flakeApp` (and completely ignore the deprecation warning ;)).
When we enter into the folder it created you can run `npm run start` as normal to verify everything is good.

But how do we build it?

There is another attribute in the `outputs` set besides `devshells` we care about. It's `packages`. Here you specify packages you want to be able to build and run and how to do it.

We'll use a function called `buildNpmPackage`. It's a fancy wrapper around a lower level `mkDerivation`. There are a lot of them for different languages and tools, e.g. `buildGoModule` for golang, and all of them take 1 argument which is an attribute set with options like `name`, `src`, `buildInputs` (dependencies), and different phases of the build process (there are a bunch) but the ones you'll care about are `buildPhase` (building the application, running the compiler) and `installPhase` (cleaning up, outputing only what we want).
```nix
flake-utils.lib.eachDefaultSystem (
  system: let
  ...
  in {
    packages = {
      sampleApp = pkgs.buildNpmPackage {};
    };
    devShells.default = pkgs.mkShell {
      ...
    };
  }
);

```
Here `buildNpmPackage` handles `buildPhase` for us once we specify the npm script to run, but we still have to specify the `installPhase`.
```nix
packages = {
  sampleApp = pkgs.buildNpmPackage {
    name = "sample";
    buildInputs = [pkgs.nodejs_24];
    src = ./flake-app;
    npmDepsHash = "";
    npmBuild = "npm run build";
    installPhase = ''
      mkdir $out
      cp -r public $out
      cp -r build $out
    '';
  };
};
```
* `name` is arbitrary and up to us
* for `buildInputs` we only need npm 
* `src` is the path to your project
* `npmBuild` is the command to run to build our app
* `installPhase` specifies what to do after out buildPhase, it has access to a env variable called `out` that specifies the path to which we have to move everything we want to output from the build process, in our case we care about the `public` and `build` directories.
* `npmDepsHash` is the hash of all the dependencies, it works the same way as package-lock.json but for all of the dependencies combined instead of for each one. We can leave it empty for now, since we don't know the hash yet and checking it manually wouldn't be the most convenient thing in the world.

To find out how to use functions a good way is to search on github `language:nix buildNpmPackage` and you can see tons (6.1k) of examples how different people use it for different projects.

To build with nix from a flake, we use the `nix build` command, it takes a path to the flake as an argument, followed by the name of the package we want to build seperated with a `#`. So the final command in our case looks like `nix build .#sampleApp`. (btw `nix develop` takes the same argument as well, but if it's not given it will look for an attribute named `default` and do that instead. Same thing applies here, if we named the package `default`, we could've just run `nix build` with no arguments for the same effect)

The first time you run this it should error saying there was a hash mismatch. That's because we left the `npmDepsHash` empty. But it also prints the hash it got so we can just copy and paste it into the `npmDepsHash` attribute.

Upon running `nix build .#sampleApp` again, once it finished you should see a `result` folder, which contains the final compiled files ready to serve.

To test it out we can run `nix run nixpkgs#python3 -- -m http.server 8000 -d ./result/build` and navigate to localhost:8000 to see the classic react spinner.
