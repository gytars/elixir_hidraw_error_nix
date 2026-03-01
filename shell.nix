{
  pkgs,
  mixEnv,
}:
let
  # define packages to install
  basePackages = with pkgs; [
    git
    elixir
    elixir-ls
    hex
    gcc
    gnumake

    (pkgs.writeShellScriptBin "update" ''
      nix flake update --commit-lock-file && ${elixir}/bin/mix deps.update --all && ${elixir}/bin/mix deps.get && ${elixir}/bin/mix compile
    '')
  ];

  # Add basePackages + optional system packages per system
  inputs =
    with pkgs;
    basePackages
    ++ lib.optionals stdenv.isLinux [ libnotify ] # For ExUnit Notifier on Linux.
    ++ lib.optionals stdenv.isLinux [ inotify-tools ]; # For file_system on Linux.

  # define shell startup command
  hooks = ''
    # this allows mix to work on the local directory
    mkdir -p .nix-mix .nix-hex
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-mix
    export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH

    export MIX_ENV=${mixEnv}

    export LANG=en_US.UTF-8
    # keep your shell history in iex
    export ERL_AFLAGS="-kernel shell_history enabled"

    ${pkgs.elixir}/bin/mix --version
    ${pkgs.elixir}/bin/iex --version
  '';
in
pkgs.mkShell {
  buildInputs = inputs;
  shellHook = hooks;
}
