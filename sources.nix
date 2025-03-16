{ pkgs ? import <nixpkgs> {} }:

builtins.fromJSON (builtins.readFile ./sources.json)