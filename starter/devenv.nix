{ config, lib, ... }:
{
  # devenv test would otherwise start it.
  processes = lib.mkIf (!config.devenv.isTesting) {
    app.exec = "cargo run";
  };
}
