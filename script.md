1. Intro, who we are, what we're gonna talk about
2. Advantages and limitations of "serverless" - when should we use it
3. What aren't we all self-hosting - the problem with manual bare-metal hosting
4. Solution - Nix + Kubernetes
5. How to easily deploy Kubernetes?
  - Problems with manual, imperative deployment of k3s
  - Easy solution using NixOS - demo
6. What is Nix in general and how do we use it?
  - Creating a project enviroment in a standard way vs with Nix
  - How do we define such environment?
  - Where are those packages coming from? - nixpkgs, and how big it is
  - NixOS - come back to the k3s deployment, brief NixOS explanation based on explained concepts of Nix
7. Managing Kubernetes with Nix - kubenix.
  - Adding kubenix to flake.nix to manage kubernetes
  - Builing Docker image from built app in Nix and integrating into cluster code
8. Summary of what we did by showing all 2-3 Nix files needed for the whole setup
