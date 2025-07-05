{ pkgs, ... }:
{
  # intentionally disabled to avoid collisions.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  # see `darwin-rebuild changelog` before changing.
  system.stateVersion = 6;

  # needed to generate nix-darwin setup in `/etc/fish`
  programs.fish = {
    enable = true;
    useBabelfish = true;
  };

  # don't forget to `chsh -s /run/current-system/sw/bin/fish`
  environment.shells = [ pkgs.fish ];
  environment.systemPackages = [ ];

  homebrew = {
    enable = true;
    casks = [
      "beeper"
      "breaktimer"
      "chatgpt"
      "signal"
      "tailscale"
      "todoist"
      "zen"
    ];
  };

  services.karabiner-elements = {
    enable = true;
    # https://github.com/nix-darwin/nix-darwin/issues/1041
    package = pkgs.karabiner-elements.overrideAttrs (old: {
      version = "14.13.0";
      src = pkgs.fetchurl {
        inherit (old.src) url;
        hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
      };
      dontFixup = true;
    });
  };

  system.keyboard = {
    enableKeyMapping = true;
    # swapped in karabiner to not affect external keyboards
    # swapLeftCtrlAndFn = true;
    userKeyMapping = [
      # caps lock -> option
      {
        HIDKeyboardModifierMappingSrc = 30064771129;
        HIDKeyboardModifierMappingDst = 30064771298;
      }
    ];
  };

  system.defaults.CustomSystemPreferences."com.apple.AdLib" = {
    allowApplePersonalizedAdvertising = false;
    allowIdentifierForAdvertising = false;
    forceLimitAdTracking = true;
    personalizedAdsMigrated = false;
  };

  system.defaults.LaunchServices = {
    # disable "Application Downloaded from Internet" popup
    LSQuarantine = false;
  };

  system.defaults.NSGlobalDomain = {
    # expand save panel by default
    NSNavPanelExpandedStateForSaveMode = true;
    NSNavPanelExpandedStateForSaveMode2 = true;
    # expand print panel by default
    PMPrintingExpandedStateForPrint = true;
    PMPrintingExpandedStateForPrint2 = true;

    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;

    # drag windows by holding ctrl + cmd and clicking anywhere in the window
    # does not work for windows without window decorations
    NSWindowShouldDragOnGesture = true;
  };

  system.defaults.dock = {
    autohide = true;
    # basically disable dock
    autohide-delay = 30.0;
    # disable workspace sorting.
    mru-spaces = false;
    # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
    expose-group-apps = true;
  };

  system.defaults.spaces = {
    # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
    spans-displays = true;
  };

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;
    FXEnableExtensionChangeWarning = false;
    FXPreferredViewStyle = "Nlsv"; # list style
    _FXSortFoldersFirst = true;
    _FXSortFoldersFirstOnDesktop = false;
    ShowPathbar = true;
    ShowStatusBar = true;
  };

  system.defaults.CustomSystemPreferences = {
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.dock" = {
      no-bouncing = true;
    };
  };
}
