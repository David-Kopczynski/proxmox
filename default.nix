{ ... }:

{
  # Automatically install all configuration from install directory
  imports = (
    builtins.map (n: toString ./install + "/${n}") (builtins.attrNames (builtins.readDir ./install))
  );
}
