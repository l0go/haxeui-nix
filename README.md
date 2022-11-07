# HaxeUI Nix Flake
This is a template for hxWidgets+HaxeUI projects using the Nix Flake feature. This allows you to consistently create development environments and build on Linux and MacOS.
## Setting up Nix
1. Install the Nix package manager if you have not yet.	Follow the [offical guide](https://nixos.org/download.html). It only takes one command to install!
2. Add ``experimental-features = nix-command flakes`` to ``~/config/nix/nix.conf`` or ``/etc/nix/nix.conf`` to enable the flake feature.
3. You may need to restart the Nix daemon. On a systemd system run ``sudo systemctl restart nix-daemon.service``.
4. Test if nix is installed by running the ``nix`` command. It should state that no subcommand is specified.
## Development
```bash
# Create a development environment with this command
nix develop
# It will create a bash shell with all of the project dependencies already loaded
# You can use it just like any other shell. For instance you can run ``haxe hxwidgets.hxml`` to build.
haxe hxwidgets.hxml
```
## Building
```bash
# Building, only requires one command
# It will create a build environment with all of the required dependencies setup and then run ``haxe hxwidgets.hxml``
# I wouldn't use this for development, only for production. It will take awhile!
nix build
```
## Clean Up
```bash
# You can remove all of the artifacts (dependencies, tools, builds) using the collect garbage command
nix-collect-garbage
```
## Project Specific Setup
I recommend that you edit the ``flake.nix`` file with the details of your project. The parts you should edit are annotated. Adding additional Haxelibs can be quite tricky for those who don't have previous experience with Nix. Try figuring it out on your own using what is currently in the flake. Contact me on the Haxe Discord if you are stuck.
