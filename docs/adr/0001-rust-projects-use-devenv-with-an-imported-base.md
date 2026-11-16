---
status: accepted
---

# Rust projects use devenv with an imported base

On 2026-11-15 the owner decided that each Rust project gets its environment from devenv 2.4
instead of a flake. A coworker who clones a project gets the same compiler, tools, git hooks and
`devenv test`. Projects import the base from this repo through their `devenv.yaml` rather than copying
it, so a fix to the base reaches a project when its `devenv.lock` moves. The compiler comes from
Nix: rust-overlay reads the project's own `rust-toolchain.toml`. rustup is gone, from the projects
and from the owner's machine. nix-config stays a flake, because it is one person's config, not a
project. Its own crate keeps the nixpkgs toolchain its system build uses.

## Considered options

- **Flakes, as before.** They can do all of this with more Nix code, but hooks and a test command
  have to be wired by hand. devenv's options are easier for a coworker who does not know Nix to read, and
  later server projects need devenv's processes and Machines anyway.
- **A starter copied with no import.** Every project would drift from the others after its copy.
  The starter is still copied, but only for the files a project owns.
- **devenv's own `devenv hook` instead of direnv.** devenv 2.x marks its direnv integration
  deprecated. The hook starts a subshell instead of changing the shell in place. The agent tooling
  runs `direnv exec`, and repos without devenv would still need direnv. Revisit when no repo with
  a non-devenv `.envrc` is left, or when devenv announces it will drop `direnvrc`.
- **A public repo.** It would need no credentials anywhere. The owner chose private.

## Consequences

- devenv loads the base's `devenv.nix` but never this repo's `devenv.yaml`. Every project's
  `devenv.yaml` therefore declares the inputs the base needs, rust-overlay and git-hooks, itself.
  The starter carries that list.
- The base reads a project's `rust-toolchain.toml` from the project root, because `./` inside the
  base points into this repo.
- Only a project sets `LD_LIBRARY_PATH`. The same variable set in two modules fails evaluation
  instead of merging.
- Projects require devenv with the constraint string `>=2.4.0`, which devenv checks against the
  CLI's version. `require_version: true` compares the CLI with the modules of the separately locked
  `devenv` input instead, and the two drift either way. The v2.4.0 tag's modules report 2.3.1, while
  the default branch locked on 2026-11-16 reports 2.4.0.
- The repo is private, so projects import it over SSH
  (`git+ssh://git@github.com/gademers/project-template`). People fetch it with their own SSH keys.
  CI fetches it with a read-only deploy key on this repo, stored as a secret in each project.
