# Beyond the 'Deploy' Button: A Modern Approach to Bare-Metal Hosting

We live in the golden age of developer convenience. With platforms like Vercel, Netlify, and Supabase, deploying a web application is often just a matter of logging in with GitHub, selecting a repository, and clicking a single button. The "ship fast" (or more like "shit fast") trend is powered by this simplicity, and it's undeniably tempting. Your Next.js app is live in minutes, and you didn't have to touch a single server.

I get it. The ease, and more importantly, **the speed** are the main selling points. You don't need a deep well of infrastructure knowledge to get your project online. But this convenience comes with hidden costs and limitations that just build up as your projects grow.

This post is for those who are curious about what lies beyond the one-click deploy. It’s for those who want more control, predictability, and a deeper understanding of their stack. I would especially recommend it to beginners looking to deploy their first app.

I am going to argue that hosting on "bare-metal" doesn't have to be the scary, manual ordeal you might imagine. In fact, with the right setup, you can create a deployment system that is far more powerful and, in the long run, just as streamlined - and that's the kind of setup I want to present you here right now.

> Actually, it's not exactly always **bare-metal**. It'll mostly likely be VPS, but I will continue to write "bare-metal" in this article, because it sounds cooler.

## The Trouble with "Serverless" Simplicity

First of all, why even care? Why wouldn't I just host my software on Vercel and forget about infrastructure at all? Well, there are serval reasons. The first is the unpredictability of pricing. We’ve all seen the tweets—the panicked posts from developers waking up to a massive, unforeseen bill from their hosting provider. It’s a recurring nightmare that highlights the opaque nature of their billing models.

Beyond the financial risk, these services are often surprisingly limited. You might start with just a simple website, but soon you need some specific database. This means subscribing to another service, with its own pricing and complexities, weaving a tangled web of third-party dependencies that are awkwardly connected. You are fundamentally constrained by the features that the hosting company decides to offer you.

However, the most significant drawback for me is the stagnation of knowledge. When you only ever click a button, you are outsourcing your understanding. What operating system is your code running on? How does networking actually function? You become a monkey clicking buttons, proficient in a specific platform's UI but not in the fundamental principles of software deployment. This knowledge is invaluable and its absence can limit your growth as an engineer.

## Hosting on bare-metal

### The Manual "Wild West" Approach

So, what's the alternative? I guess the first thing that can come to begginer's mind is the very manual way. You SSH into the machine, you manually fetch your code, compile it, or maybe even just copy the binary with `scp`, thinking it might work just like that. If you need a runtime, you install the runtime. But then you need your backend database as well, okay, so you install that dependency as well. And then you need 20 more dependencies, so you install them one by one. Very time-consuming! What if one of the dependencies you install has a slightly different version than the one you worked with locally and your app breaks? A very inconsistent environment. And you have to do this each time for each new server you plan to host on! Baaaad!

But okay, say you've got your pretty web app running, but it's only accessible locally now. So you set up some firewalls with `iptables`. Great, you can see your app is public now. But after you leave the SSH session, it's gone! Okay, so you learn how to use `systemctl` and you fire up a daemon to run it in the background. Maybe you even set it up to restart after it fails. But then you want to move to the next version of your app or roll back to the previous one because some bugs came up. And what do you do when you want to rent a second server? You do this all again and manage two servers manually? 

I could talk about ways of solving these problems manually, but you can see that this is not the greatest way of hosting software on bare metal.

> Frankly, I'm not even entirely sure what the truly "hard way" looks like, because right from the start of my career, I was introduced to a far more elegant and comfortable approach to hosting on your own hardware.

### A Glimmer of Hope with Docker

So what's the alternative? You think maybe you could use Docker, or even Docker Compose instead. And indeed, it is a much better idea. We get way more consistent environments generated from a `Dockerfile`, which is pretty nice. We don't have to clone our source code to the machine and we don't have to manually install dependencies—very. Great! We just have to install Docker or another container runtime, and it will do this hard work for us in a very consistent way.

If you're good, you're event going to write the `docker-compose.yml` and run Docker Compose so your services, so that the backend and the database, can easily talk to each other. Although, with scale, managing these individual containers can become difficult over time. With more complex systems, we often get complicated networking, there is no auto-scaling, so your billion-dollar-idea app won't magically spawn a new container when it finally receives some more traffic. I don't think there is self-healing either. We also have storage difficulties; you can't easily deploy a database with persistent storage. We are at a pretty good point, but we need a better solution.

### The Gold Standard

So this brings me to the final hosting solution, which is the very popular, gold standard - **Kubernetes**. You might think, "Oh no, another thing to learn!" and yes, there's a learning curve. But think about all the problems we just talked about. Kubernetes solves them, so you don't event have to think about them at all, most of the time. You no longer think about individual machines or containers. You think about the "desired state" of your application. You just tell Kubernetes, "Hey, I want three copies of my app running at all times, connected to this database." And Kubernetes makes it so. (turns out there is also a tool called `kubectl-ai` so you can literally "say" this to Kubernetes lol).

What happens if a container crashes? You don't care! Kubernetes sees it's gone and spins up a new one automatically. That's self-healing right there. What about that scaling problem? You get a sudden spike in traffic? Kubernetes can be configured to automatically scale up the number of your app containers to handle the load and then scale them back down when things quiet down. It's like magic! Rolling out a new version of your app is a breeze with zero downtime, and if you mess up, rolling back is just as simple. It handles the complex networking between services and even makes managing persistent storage for your stateful applications like databases a solvable problem. It's the ultimate orchestrator that takes all the manual, error-prone work and automates it. For serious hosting on bare metal, **this is the way**.

## Soo, deploying?

Alright, now that we see Kubernetes is the best way, how do we actually deploy it to the server? I mean, it won't magically appear on our rented Hetzner VPS. So wait, does this mean we're back to killing all the progress we made by manually SSHing into the machine to install and configure Kubernetes? Well, yes and no. It's true that for the first time, we have to SSH in there. But we won't actually manually install a binary like k3s and run it with the correct flags and configuration. Hell no. We're doing this the right way, the easy way. And the secret for that is a very specific Linux distribution we will use on our server: **NixOS**.

This brings us to probably the most important topic of this post, which is Nix itself. This, alongside Kubernetes, is the fundamental technology for our final setup. We won't just use NixOS for the deployment; we will also describe and modify our deployed apps on the Kubernetes cluster in the **Nix language** - more on that later. Because this is such an important topic, I want to briefly talk about it. The next section is mainly for people who have never used or even heard about Nix, but even if you have, I would still recommend you scan it quickly to know where we're at.

## What On Earth Is Nix?

So what is this Nix thing I just dropped on you? It sounds complicated, but let's break it down. First off, Nix isn't just one thing, which is where people can get confused. You can think of it as **three things in one** that are based on each other: it's a programming language, a package manager, and a full-blown operating system (NixOS). The magic is how they all work together. At its heart, Nix language, which is responsible for build Nix packages, is **declarative and purely functional**. This means you don't write a list of steps to set something up; instead, you write a single configuration file that describes the exact final state you want.

Nix is also a very **deterministic** which means that a package definition in Nix language will always build the exact same software, bit for bit, every single time. It doesn't matter what other libraries or junk you have installed on your system, you don't have to install anything besides Nix itself. It builds everything in its own isolated sandbox, eliminating the "but it works on my machine!" problem forever. This deterministic power is what makes its package repository, **nixpkgs**, a reality. It's a gigantic collection where each package is just a functional declaration of what it is and what it depends on. When you ask for a package, Nix builds it and all of its dependencies from the ground up in that same perfectly reproducible way.

And here’s a fact that might surprise you if you're new to this: **nixpkgs** is the single biggest package repository in the world in terms of the number of available packages. Yes, you heard that right. Homebrew, `apt`, or any other manager you can think of is a tiny little thing next to the sheer volume of software available in nixpkgs. It suprised me when I started with Nix and I'm sure it will suprise many more. Seems like it's one of the best-kept secrets in tech, but it's an absolute giant. And we're going to use this power to declare our entire server configuration, including Kubernetes itself, in reproducible Nix files.

Even though I tried my best to summarize it here, I know it might be very confusing now what exactly this Nix thing is, so I think it's the best to show you some examples:

<details>
<summary>Nix in practice.</summary>

## Preface

Note that we don't expect you to understand exactly how this all works at first, but the example Flake in this tutorial is made in a way that you can just copy it and use it in your projects with minimal changes. Once you start using it, asking LLMs or Googling how to make it do exactly what you want is the best way to learn Nix.

If you haven’t already enabled Flakes, add the following line to your `/etc/nix/nix.conf` or `~/.config/nix/nix.conf`:

```conf
experimental-features = nix-command flakes
```

## What Are They

Flakes are technically an *experimental* feature, but the community adopted them as the default way to configure stuff with Nix because of a few advantages over the legacy *channels*. The big two advantages are:

### 1. `flake.lock` File

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

### 2. All Dependencies Are Explicit

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

(If you put it in a Git repo, you'll see an error saying it's not tracked by Git. This is to prevent unwanted unversioned changes. Either add it to Git with `git add`, or move it out of the Git repo. You don't have to commit it, staging it is enough.)

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

</details>

## Deploying Kubernetes to NixOS

TODO

## Nix For Cluster State

We have our Kubernetes cluster deployed on NixOS, so now let's go back to why we went this hard on Nix. It's great how K8s does most of the things for us automatically, like scaling and upgrading with no downtime. But after some time, you might notice that managing the cluster itself can be pretty hard. Kubernetes resources are defined in YAML files that live inside the cluster, and the only way you can access them is through your cluster's API (using tools like `kubectl`). So every time you need to change the tag of your software image to upgrade to a new version, you have to execute something like `kubectl edit` and change it.

But what if you want to roll back to a known-good state of the application from a week ago? You could just manage a repository of YAML files, but you will quickly find yourself repeating a lot of code when creating very similar resources for deploying similar applications. A single application usually needs a whole set of Kubernetes resources, not just one—like the standard Deployment/Service/Ingress combo for a public app. Wouldn't it be great if we had a way to **programmatically declare the state of all resources**, so we could write reusable functions instead of copying and pasting pure YAML? That's where we connect it all with Nix again.

If we have already defined the state of our server in configuration.nix to deploy Kubernetes, why don't we define the state of the whole Kubernetes cluster in Nix as well? All of the resources, defined in a purely functional, deterministic, programmatic way.

`kubenix`

## Connecting to the build system

TODO
