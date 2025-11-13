{
  ...
}:
{
  programs.wofi = {
    enable = true;
  };

  home.file.".config/wofi" = {
    enable = true;
    source = ./config;
  };
}
