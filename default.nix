{ pkgs ? (import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/c95bf18beba4290af25c60cbaaceea1110d0f727.tar.gz";
  sha256 = "sha256:1dgix450hcp7rgxnf83vrsgpbjnbiccllp7mjkziyx94a13jdraz";
}) {}), ... }:
{
  harvester-cluster-repo = import ./harvester-cluster-repo.nix { inherit pkgs; };
  inherit pkgs;
}
