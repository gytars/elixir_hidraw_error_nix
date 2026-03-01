# Doesn't work:

```sh
git checkout main
rm -rf _build deps
mix deps.get
mix deps.compile
```

# This works, but why not the above..

```sh
git checkout main
rm -rf _build deps
mix deps.get
mix deps.compile elixir_make
mix deps.compile
iex -S mix
```

```iex
ElixirHidrawErrorNix.hello

ElixirHidrawErrorNix.enumerate
```

# Works using nix, while commenting out hidraw:

```sh
git checkout nix-build-working-without-hidraw
rm -rf _build deps
mix deps.get
mix deps.compile
mix deps.nix
mix deps.compile
nix build --print-build-logs

result/bin/elixir_hidraw_error_nix start_iex
```

```iex
ElixirHidrawErrorNix.hello
```
