{
  pkgs ? import <nixpkgs> {
    overlays = [ (fin: pre: { glew = pre.glew.override { enableEGL = true; }; }) ];
  },
}:

pkgs.callPackage ./package.nix { }
