self: super: {
  # rust-bin is provided by oxalica/rust-overlay via flake input
  # To use nightly: pkgs.rust-bin.nightly.latest.default
  # To pin a date:  pkgs.rust-bin.nightly."2025-01-01".default
  # To add targets: rust-bin.stable.latest.default.override { targets = [ "wasm32-unknown-unknown" ]; }
}
