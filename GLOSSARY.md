# Project template

The devenv setup every Rust project shares, so that a coworker gets the same environment and the
same commands in each repo. Terms here name its parts and the commands a project answers to.

## Language

**Project template**:
The private `gademers/project-template` repo: the base and the starter, with this glossary and its
ADRs.
_Avoid_: template on its own (it used to mean a folder copied once), kit, devenv-shared

**Base**:
The devenv module in the project template that every project imports from its `devenv.yaml`. A
project picks up a change to it only when its `devenv.lock` moves.
_Avoid_: shared module, common config, template

**Starter**:
The folder in the project template that a new project copies once: `devenv.yaml`, `devenv.nix`,
`rust-toolchain.toml`, `.envrc`, `.gitignore` and the CI workflow. After the copy the project owns
those files; only the base stays shared.
_Avoid_: template, scaffold, skeleton

**`devenv test`**:
What must pass before a change merges: the git hooks on every file, then clippy and the tests the
base defines. CI runs the same command.
_Avoid_: check, gate, the tests (`cargo test` is one part of it), CI (where it also runs)
