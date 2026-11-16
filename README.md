# project-template

The project template holds the base, which every Rust project imports into its devenv environment,
and the starter, which a new project copies once. `GLOSSARY.md` defines the terms, and `docs/adr/`
records the decisions.

## Onboarding

You need a NixOS machine and an SSH key on your GitHub account.

1. Install devenv 2.4.0 or newer, trust its binary cache and enable direnv. The stable channel's
   devenv is older, so take it from nixpkgs-unstable. In your NixOS configuration:

   ```nix
   environment.systemPackages = [ pkgs.devenv ]; # pkgs from nixpkgs-unstable
   nix.settings.trusted-substituters = [ "https://devenv.cachix.org" ];
   nix.settings.trusted-public-keys = [
     "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
   ];
   programs.direnv.enable = true;
   ```

   The cache goes in `trusted-substituters`, not `substituters`. devenv asks the Nix daemon for it
   on each run, and your system builds never query it. You do not need to be a Nix trusted user.
   `programs.direnv.enable` installs direnv and hooks it into your shell.

   If a devenv run warns `ignoring untrusted substituter`, the cache is missing from
   `trusted-substituters`, and devenv builds from source what the cache would serve. Warnings of
   the form `ignoring the client-specified setting '<name>', because it is a restricted setting and
   you are not a trusted user`, for `trusted-public-keys`, `always-allow-substitutes`,
   `http-connections` and `system`, are expected. The daemon already has the key from your
   configuration.

2. Ask the owner for read access to each project you work on. For foodborg, also ask for
   `gademers/food-encyclopedia`, its submodule. Git clones them over SSH with the key in your SSH
   agent, so check that `ssh-add -l` lists it. The project template is public, and Nix fetches the
   base over HTTPS with no key.

3. Clone a project and let direnv load it:

   ```sh
   git clone git@github.com:gademers/<project>.git
   cd <project>
   direnv allow
   ```

   The first load downloads or builds the project's toolchain. After that, direnv loads the
   environment whenever you `cd` into the project and unloads it when you leave.

## Commands

- `devenv test` runs the git hooks on every file, then clippy with warnings as errors, then the
  tests. A change merges only when it passes. CI runs the same command.
- `devenv up` starts the project's processes.
- Without a terminal, as in CI, `devenv test` prints devenv's task lines, such as
  `devenv:git-hooks:run`, but not each hook's result or a passing test's output.
  `devenv --verbose test` prints both.

## Layout

Every project imports `base/` through its `devenv.yaml`. A new project copies `starter/` once and
then owns those files.

## Git hooks and worktrees

Loading a project's environment installs the rustfmt hook in `.git/hooks` and writes
`.pre-commit-config.yaml`, which git ignores, into the working tree. Every worktree of a clone
shares `.git/hooks`, but each needs its own config file, which it gets when it first loads the
environment. A worktree on a branch from before the project moved to devenv has no devenv
environment to load, so pre-commit refuses its commits with "No .pre-commit-config.yaml file was
found" until the branch merges the move. Until then, `PRE_COMMIT_ALLOW_NO_CONFIG=1 git commit`
skips the hook.

## CI

The starter's workflow runs `devenv test` on GitHub's standard runner, which starts with about
15 GB free on `/`. A cold Bevy build needs more, an 11 GB `target/` beside a 4 GB devenv profile,
and its runner most likely runs out of disk. Such a run leaves no log. Its `devenv test` step has
no conclusion and no end time, and `gh run view --log-failed` answers `log not found`
(`BlobNotFound`). Only in a project whose runs fail that way, add this step before
`devenv test`. It frees about 19 GB in under 90 s.

```yaml
      - name: Free disk space
        run: |
          df -h /
          sudo rm -rf /usr/share/dotnet /usr/local/lib/android /opt/ghc /opt/hostedtoolcache/CodeQL
          df -h /
```

While it builds the profile, devenv logs a `colliding subpath (ignored)` warning for
`bin/cargo-fmt` in `…-rustfmt-wrapped` and in `…-rust-default-<version>`. The warning is harmless.
The hook's `rustfmt-wrapped` references `rust-default-<version>` (`nix-store -q --references`), so
both are the pinned toolchain, and the hook formats with the project's own rustfmt.
