# Create a derivation that contains aspell and selected dictionaries.
# Composition is done using `pkgs.buildEnv`.

{ aspell
, aspellDicts
, makeWrapper
, buildEnv
}:

let
  # Dictionaries we want
  dicts = aspellDicts;

in buildEnv {
  name = aspell.name;
  buildInputs = [ makeWrapper ];
  paths = [ aspell ] ++ dicts;
  postBuild = ''
    # Construct wrappers in /bin
    unlink "$out/bin"
    mkdir -p "$out/bin"
    pushd "${aspell}/bin"
    for prg in *; do
      if [ -f "$prg" ]; then
        makeWrapper "${aspell}/bin/$prg" "$out/bin/$prg" --set ASPELL_CONF "dict-dir $out/lib/aspell"
      fi
    done
    popd
  '';
}
