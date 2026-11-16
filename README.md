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

2. Ask the owner for read access to `gademers/project-template`. For foodborg, also ask for
   `gademers/food-encyclopedia`. Nix fetches both over SSH with the key in your SSH agent, so check
   that `ssh-add -l` lists it.

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

## Layout

Every project imports `base/` through its `devenv.yaml`. A new project copies `starter/` once and
then owns those files.
