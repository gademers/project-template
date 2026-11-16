{
  config,
  lib,
  pkgs,
  ...
}:
{
  languages.rust.enable = true;
  # ./ here points into the project template, so read the project's own file.
  languages.rust.toolchainFile = config.devenv.root + "/rust-toolchain.toml";
  # Pin the standard library source to the toolchain's rust-src, whatever devenv's default is.
  env.RUST_SRC_PATH = lib.mkForce "${config.languages.rust.toolchainPackage}/lib/rustlib/src/rust/library";

  git-hooks.hooks.rustfmt.enable = true;

  packages = [ pkgs.bacon ];

  # Clippy runs here rather than as a hook, so commits stay fast.
  enterTest = ''
    cargo clippy --workspace --all-targets -- -D warnings
    cargo test --workspace
  '';
}
