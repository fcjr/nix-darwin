{ config, lib, ... }:

with lib;

let
  # Should only be used with options that previously used floats defined as strings.
  inherit (config.lib.defaults.types) floatWithDeprecationError;

persistentOther = types.submodule {
    options = {
      path = lib.mkOption {
        type = types.either types.path types.str;
        description = "Path as either a path type or string";
      };
      arrangement = let
        values = [
          "automatic"       # 0
          "name"            # 1
          "date-added"      # 2
          "date-modified"   # 3
          "date-created"    # 4
          "kind"            # 5
        ];
      in lib.mkOption {
        type = types.nullOr (types.enum values);
        default = null;
        description = "Sort items by specified criteria";
        apply = value: lib.lists.findFirstIndex (x: x == value) 0 values;
      };
      showas = let
        values = [
          "automatic"      # 0
          "fan"            # 1
          "grid"           # 2
          "list"           # 3
        ];
      in lib.mkOption {
        type = types.nullOr (types.enum values);
        default = null;
        description = "View content as specified style";
        apply = value: lib.lists.findFirstIndex (x: x == value) 0 values;
      };
      displayas = let
        values = [
          "stack"          # 0
          "folder"         # 1
        ];
      in lib.mkOption {
        type = types.nullOr (types.enum values);
        default = null;
        description = "Display item as stack or folder";
        apply = value: lib.lists.findFirstIndex (x: x == value) 0 values;
      };
    };
  };
in {
  imports = [
    (mkRenamedOptionModule [ "system" "defaults" "dock" "expose-group-by-app" ] [ "system" "defaults" "dock" "expose-group-apps" ])
  ];

  options = {

    system.defaults.dock.appswitcher-all-displays = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Whether to display the appswitcher on all displays or only the main one. The default is false.
      '';
    };

    system.defaults.dock.autohide = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Whether to automatically hide and show the dock. The default is false.
      '';
    };

    system.defaults.dock.autohide-delay = mkOption {
      type = types.nullOr floatWithDeprecationError;
      default = null;
      example = 0.24;
      description = ''
        Sets the speed of the autohide delay. The default is given in the example.
      '';
    };

    system.defaults.dock.autohide-time-modifier = mkOption {
      type = types.nullOr floatWithDeprecationError;
      default = null;
      example = 1.0;
      description = ''
        Sets the speed of the animation when hiding/showing the Dock. The default is given in the example.
      '';
    };

    system.defaults.dock.dashboard-in-overlay = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Whether to hide Dashboard as a Space. The default is false.
      '';
    };

    system.defaults.dock.enable-spring-load-actions-on-all-items = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Enable spring loading for all Dock items. The default is false.
      '';
    };

    system.defaults.dock.expose-animation-duration = mkOption {
      type = types.nullOr floatWithDeprecationError;
      default = null;
      example = 1.0;
      description = ''
        Sets the speed of the Mission Control animations. The default is given in the example.
      '';
    };

    system.defaults.dock.expose-group-apps = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Whether to group windows by application in Mission Control's Exposé. The default is false.
      '';
    };

    system.defaults.dock.launchanim = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Animate opening applications from the Dock. The default is true.
      '';
    };

    system.defaults.dock.mineffect = mkOption {
      type = types.nullOr (types.enum [ "genie" "suck" "scale" ]);
      default = null;
      description = ''
        Set the minimize/maximize window effect. The default is genie.
      '';
    };

    system.defaults.dock.minimize-to-application = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Whether to minimize windows into their application icon.  The default is false.
      '';
    };

    system.defaults.dock.mouse-over-hilite-stack = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Enable highlight hover effect for the grid view of a stack in the Dock.
      '';
    };

    system.defaults.dock.mru-spaces = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Whether to automatically rearrange spaces based on most recent use.  The default is true.
      '';
    };

    system.defaults.dock.orientation = mkOption {
      type = types.nullOr (types.enum [ "bottom" "left" "right" ]);
      default = null;
      description = ''
        Position of the dock on screen.  The default is "bottom".
      '';
    };

    system.defaults.dock.persistent-apps = mkOption {
      type = let
        taggedType = types.attrTag {
              app = mkOption {
                description = "An application to be added to the dock.";
                type = types.str;
              };
              file = mkOption {
                description = "A file to be added to the dock.";
                type = types.str;
              };
              folder = mkOption {
                description = "A folder to be added to the dock.";
                type = types.str;
              };
              spacer = mkOption {
                description = "A spacer to be added to the dock. Can be small or regular size.";
                type = types.submodule {
                  options.small = mkOption {
                    description = "Whether the spacer is small.";
                    type = types.bool;
                    default = false;
                  };
                };
              };
            };

        simpleType = types.either types.str types.path;
        toTagged = path: { app = path; };
        in
      types.nullOr (types.listOf (types.coercedTo simpleType toTagged taggedType));
      default = null;
      example = [
        { app = "/Applications/Safari.app"; }
        { spacer = { small = false; }; }
        { spacer = { small = true; }; }
        { folder = "/System/Applications/Utilities"; }
        { file = "/User/example/Downloads/test.csv"; }
      ];
      description = ''
        Persistent applications, spacers, files, and folders in the dock.
      '';
      apply =
      let
        toTile = item: if item ? app then {
        tile-data.file-data = {
          _CFURLString = item.app;
          _CFURLStringType = 0;
        };
        } else if item ? spacer then {
          tile-data = { };
          tile-type = if item.spacer.small then "small-spacer-tile" else "spacer-tile";
        } else if item ? folder then {
          tile-data.file-data = {
            _CFURLString = "file://" + item.folder;
            _CFURLStringType = 15;
          };
          tile-type = "directory-tile";
        } else if item ? file then {
          tile-data.file-data = {
            _CFURLString = "file://" + item.file;
            _CFURLStringType = 15;
          };
          tile-type = "file-tile";
        } else item;
      in
      value: if value == null then null else map toTile value;
    };

    system.defaults.dock.persistent-others = mkOption {
      type = types.nullOr (types.listOf (types.oneOf [ types.path types.str persistentOther ]));
      default = null;
      example = [ "~/Documents" "~/Downloads" ];
      description = ''
        Persistent folders in the dock.
      '';
      apply = value:
        if !(lib.isList value)
        then value
        else map (folder: 
          let
            folderPath = if builtins.isAttrs folder then toString folder.path else toString folder;
            isSimplePath = !(builtins.isAttrs folder);
          in {
            tile-data = {
              file-data = {
                _CFURLString = "file://" + folderPath;
                _CFURLStringType = 15;
              };
            } // (if isSimplePath then {} else lib.filterAttrs (n: v: v != null) {
              arrangement = folder.arrangement;
              showas = folder.showas;
              displayas = folder.displayas;
            });
            tile-type = if lib.strings.hasInfix "." (lib.last (lib.splitString "/" folderPath))
              then "file-tile"
              else "directory-tile";
          }) value;
    };

    system.defaults.dock.scroll-to-open = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Scroll up on a Dock icon to show all Space's opened windows for an app, or open stack. The default is false.
      '';
    };

    system.defaults.dock.show-process-indicators = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Show indicator lights for open applications in the Dock. The default is true.
      '';
    };

    system.defaults.dock.showhidden = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Whether to make icons of hidden applications tranclucent.  The default is false.
      '';
    };

    system.defaults.dock.show-recents = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Show recent applications in the dock. The default is true.
      '';
    };

    system.defaults.dock.slow-motion-allowed = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Allow for slow-motion minimize effect while holding Shift key. The default is false.
      '';
    };

    system.defaults.dock.static-only = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Show only open applications in the Dock. The default is false.
      '';
    };

    system.defaults.dock.tilesize = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = ''
        Size of the icons in the dock.  The default is 64.
      '';
    };

    system.defaults.dock.magnification = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Magnify icon on hover. The default is false.
      '';
    };

    system.defaults.dock.largesize = mkOption {
      type = types.nullOr (types.ints.between 16 128);
      default = null;
      description = ''
        Magnified icon size on hover. The default is 16.
      '';
    };

    system.defaults.dock.wvous-tl-corner = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
      description = ''
        Hot corner action for top left corner. Valid values include:

        * `1`: Disabled
        * `2`: Mission Control
        * `3`: Application Windows
        * `4`: Desktop
        * `5`: Start Screen Saver
        * `6`: Disable Screen Saver
        * `7`: Dashboard
        * `10`: Put Display to Sleep
        * `11`: Launchpad
        * `12`: Notification Center
        * `13`: Lock Screen
        * `14`: Quick Note
      '';
    };

    system.defaults.dock.wvous-bl-corner = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
      description = ''
        Hot corner action for bottom left corner. Valid values include:

        * `1`: Disabled
        * `2`: Mission Control
        * `3`: Application Windows
        * `4`: Desktop
        * `5`: Start Screen Saver
        * `6`: Disable Screen Saver
        * `7`: Dashboard
        * `10`: Put Display to Sleep
        * `11`: Launchpad
        * `12`: Notification Center
        * `13`: Lock Screen
        * `14`: Quick Note
      '';
    };

    system.defaults.dock.wvous-tr-corner = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
      description = ''
        Hot corner action for top right corner. Valid values include:

        * `1`: Disabled
        * `2`: Mission Control
        * `3`: Application Windows
        * `4`: Desktop
        * `5`: Start Screen Saver
        * `6`: Disable Screen Saver
        * `7`: Dashboard
        * `10`: Put Display to Sleep
        * `11`: Launchpad
        * `12`: Notification Center
        * `13`: Lock Screen
        * `14`: Quick Note
      '';
    };

    system.defaults.dock.wvous-br-corner = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
      description = ''
        Hot corner action for bottom right corner. Valid values include:

        * `1`: Disabled
        * `2`: Mission Control
        * `3`: Application Windows
        * `4`: Desktop
        * `5`: Start Screen Saver
        * `6`: Disable Screen Saver
        * `7`: Dashboard
        * `10`: Put Display to Sleep
        * `11`: Launchpad
        * `12`: Notification Center
        * `13`: Lock Screen
        * `14`: Quick Note
      '';
    };

    };
}
