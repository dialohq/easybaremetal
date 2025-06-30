# Beyond the 'Deploy' Button: A Modern Approach to Bare-Metal Hosting

It's really a depressing thing, in my opinion, that some people just refuse to learn.

We live in the golden age of developer convenience. With platforms like Vercel, Netlify, and Supabase, deploying a web application is often just a matter of logging in with GitHub, selecting a repository, and clicking a single button. The "ship fast" (or more like "shit fast") trend is powered by this simplicity, and it's undeniably tempting. Your Next.js app is live in minutes, and you didn't have to touch a single server.

I get it. The ease, and more importantly, **the speed** are the main selling points. You don't need a deep well of infrastructure knowledge to get your project online. But this convenience comes with hidden costs and limitations that just build up as your projects grow.

This post is for those who are curious about what lies beyond the one-click deploy. It’s for those who want more control, predictability, and a deeper understanding of their stack. I would especially recommend it to beginners looking to deploy their first app.

I am going to argue that hosting on "bare-metal" doesn't have to be the scary, manual ordeal you might imagine. In fact, with the right setup, you can create a deployment system that is far more powerful and, in the long run, just as streamlined - and that's the kind of setup I want to present you here right now.

> Actually, it's not exactly always **bare-metal**. It'll mostly likely be VPS, but I will continue to write "bare-metal" in this article, because it sounds cooler.

## The Trouble with "Serverless" Simplicity

First of all, why even care? Why wouldn't I just host my software on Vercel and forget about infrastructure at all? Well, there are serval reasons. The first is the unpredictability of pricing. We’ve all seen the tweets—the panicked posts from developers waking up to a massive, unforeseen bill from their hosting provider. It’s a recurring nightmare that highlights the opaque nature of their billing models.

Beyond the financial risk, these services are often surprisingly limited. You might start with just a simple website, but soon you need some specific database. This means subscribing to another service, with its own pricing and complexities, weaving a tangled web of third-party dependencies that are awkwardly connected. You are fundamentally constrained by the features that the hosting company decides to offer you.

However, the most significant drawback for me is the stagnation of knowledge. When you only ever click a button, you are outsourcing your understanding. What operating system is your code running on? How does networking actually function? You become a monkey clicking buttons, proficient in a specific platform's UI but not in the fundamental principles of software deployment. This knowledge is invaluable and its absence can limit your growth as an engineer.

## The Misunderstood Fear of the Command Line

So, what's the alternative? The phrase "bare-metal" often conjures images of archaic, painful processes. Many developers, especially newcomers, imagine having to manually SSH into a virtual machine, wrestle with `systemd` to fire up some demon, compile a binary, copy it over, and configure firewalls. That's what I did for the very first time. But to be honest, I'm not even entirely sure what the truly "hard way" looks like, because right from the start of my career, I was introduced to a far more elegant and comfortable approach to hosting on your own hardware.

People are scared they’ll get bogged down in manual, repetitive tasks. And yes, there is an initial manual setup when you first provision a machine. But I want to talk about a way of building an infrastructure that, while requiring more upfront effort than a click-to-deploy service, offers an incredible ROI. Once this system is in place, you can deploy all of your applications with speed and efficiency, reclaiming full control in the process. 

I want to present you a very specific setup that revolves around Kubernetes, ArgoCD, and the transformative power of Nix.

## Kubernetes and ArgoCD

Bare-metal can be hard, which is precisely why a tool like Kubernetes exists. It solves a myriad of problems for you right out of the box. It handles scaling your applications up and down, automates rollbacks if a deployment goes wrong, and manages all the complex networking and configuration between your services. It’s a robust foundation for any serious infrastructure.

But Kubernetes, by itself, has a fundamental problem: you typically manage it imperatively. You use tools like kubectl to send commands to your cluster's API. This approach lacks a crucial element: a clear, versioned history of your infrastructure's state. You might have a collection of YAML files describing your deployments, but how do you know what the state of your entire cluster looked like a week ago? Rolling back to a version from two deployments ago can be a convoluted process. You lose the ability to have a single source of truth under version control.

This is where ArgoCD slots into place. It’s a very popular tool that implements GitOps for K8s. The concept is simple: you maintain a Git repository containing all the YAML files that describe your desired all of your Kubernetes cluster's resources. ArgoCD continuously monitors this repository and compares it to the live state of your cluster. If it detects any difference, it automatically makes the necessary API calls to sync the cluster with the state defined in your Git repo.

Suddenly, the problems of imperative management disappear. Your Git repository becomes the single source of truth. You have a full git log of every change ever made to your infrastructure. You can view the exact state of your cluster at any point in time. Rolling back is as simple as a git revert. This is our goal: a declarative, version-controlled way to describe our entire infrastructure.

## A Detour into Nix: The Power of Declarative Builds

Now, before we go further, I need to shift topics for a moment and introduce the tool that elevates this entire setup from "good" to "transformative." This isn't a full tutorial on Nix, but I want to explain the core idea for anyone who's new to it.

At its heart, Nix is a tool for building and managing software in a purely deterministic way. The central philosophy is this: you declaratively describe *what* you need in a file using the Nix language, and Nix builds it for you, guaranteeing the exact same result every single time, on any machine.

Imagine you're starting a new project. Instead of manually installing Node.js, Python, and some command-line tools, you create a file, say `flake.nix`. In this file, you simply list the packages you need: `pkgs.nodejs`, `pkgs.go`, `pkgs.jq`. When you run a command like `nix develop`, Nix creates a sandboxed shell environment containing precisely those tools at those exact versions. Your main system remains untouched. Anyone on your team can run the same command and get an identical development environment, solving the "it works on my machine" problem forever.

Now, take that concept and scale it up. If we can declaratively describe a small development environment, what if we could describe an entire operating system the same way? That is exactly what NixOS is. It’s a Linux distribution where the entire system configuration—from the kernel version, to user accounts, running services, and firewall rules—is defined in a single file, `configuration.nix`. You make a change to this file, run a single command, and NixOS builds and activates the new system configuration. It's consistent, reproducible, and you can even roll the entire OS back to a previous state if something goes wrong.

## Unifying Our Infrastructure with Nix

So, how does this connect back to our setup? A Kubernetes cluster managed by ArgoCD is powerful, but we still have a couple of problems. First, how do we deploy and manage Kubernetes itself on our bare-metal server? This is where NixOS shines. We can simply open our `configuration.nix` file, add a few lines to enable the Kubernetes service and configure its networking and firewall rules, and run a command. Just like that, we have a fully functional Kubernetes cluster, managed declaratively alongside the rest of our operating system.

The second problem lies with ArgoCD. While GitOps is great, it can lead to a repository bloated with thousands of lines of verbose and repetitive YAML. If you have ten microservices, you likely have ten very similar-looking YAML files for their deployments. We want to avoid this boilerplate and write something more expressive.

If Nix is so good at building things deterministically from a declarative setup, why don't we "build" our entire cluster configuration this way? This is where tools like `Nixidy` come in. Instead of writing raw YAML, we write Nix code. We can create functions in the Nix language to generate our Kubernetes resources. A function `mkDeployment` could take a name and an image, and produce the entire YAML for that deployment. This allows us to abstract away the repetition and manage our cluster's configuration with a real programming language, generating the final YAML files that ArgoCD will then track.

## The Cherry on Top: The Connected Build System

At this point, we have a beautiful setup. Our Kubernetes cluster is deployed and managed effortlessly with NixOS. The state of all our applications within that cluster is described concisely in Nix code, which generates the YAML for ArgoCD. But we didn't choose Nix by accident. We could have deployed Kubernetes on Ubuntu and used another templating tool like Jsonnet—which ArgoCD also supports—to generate our YAMLs.

The real reason we chose Nix, the true cherry on top, is its ability to connect our application build system directly to our infrastructure code.

You don't *have* to do this. You can absolutely continue to write a Dockerfile, build your image, push it to a registry, and then copy and paste the new image tag into your Nix infrastructure code. That's still a huge improvement. But the ultimate power comes from letting Nix handle everything. You can write a Nix expression that builds your application *and* packages it into a Docker image. Your infrastructure code can then directly reference the output of that build.

Imagine this fully automated workflow, perhaps triggered on a push to your main branch:

1.  A code change is pushed to your application's source.
2.  Your CI pipeline runs a Nix command to build the infrastructure.
3.  Nix sees that the application code, an input to the Docker image, has changed. It first rebuilds your app and produces a new Docker image with a new, unique tag.
4.  Because the image tag has changed, the Nix infrastructure code that references it is now changed too.
5.  Nix re-evaluates the infrastructure code, generating new Kubernetes YAML files containing the brand-new image tag.
6.  These updated YAML files are automatically pushed to your GitOps repository.
7.  ArgoCD detects the change and rolls out the new version to your cluster.

This creates a seamless, end-to-end declarative pipeline, from a line of code all the way to production. It's a system that is robust, transparent, and gives you complete, reproducible control over the entire lifecycle of your software. It is, I believe, the modern, elegant answer to hosting on bare-metal.
