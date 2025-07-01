# Why not docker by itself 
Running containers by themselves is fine for isolated single instance
services. But it can quickly become a pain in the ass if you want some
more control. Writing the k8s manifests is very easy and lets you do
more in the future. `(too little, need better arguments)`

# The cure (nix)
`insert content lol`

# Idk, man it works on *every* machine
By leveraging the strengths of nix the package manager and nix the language
in a full blown linux distro, you eliminate the problem of having different
dependency versions which is the most common cause of issues between hosts.
Making self hosting potentially more stable then using a 3rd party service that
noone outside of the company actually knows how it works under the hood.
(actually flakes fix this and you have to enable them but the community collectively
accepted flakes as THE way to use nix [show how to enable them in config])

# Look ma! no hands! 
And the best thing about this is, it's all open source and standardized. That means,
lets say an undisclosed server provider we'll call hamtzner you've been renting a server
from for years has suddenly and without warning raised it's prices 500%. Now that's
just disrespectful and you won't stand for it so you decide do change your server provider.
So you find a different provider that *doesn't* charge 500% the market rate for servers.
Set up a NixOS machine and run 3 commands.

  1. `scp  -r <old-server>:/etc/nixos ./`
  2. `scp -r ./nixos <new-server>:/etc/`
  (2.5. `ssh <new-server>`)
  3. `nixos-rebuild switch`

And your new setup is the exact same. Let's see this in action.

                              ** do the thing **
                ** wait for applause and give autographs ** 
