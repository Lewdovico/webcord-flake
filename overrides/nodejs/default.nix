{
  lib,
  pkgs,
  # dream2nix
  satisfiesSemver,
  ...
}: {
  webcord.runBuild = let
    desktopItem = pkgs.makeDesktopItem {
      name = "webcord";
      desktopName = "WebCord";
      genericName = "Discord and Fosscord client";
      exec = "webcord";
      icon = "webcord";
      categories = ["Network" "InstantMessaging"];
      mimeTypes = ["x-scheme-handler/discord"];
    };

    buildInfo = pkgs.writeTextFile {
      name = "buildInfo.json";
      text = builtins.toJSON {
        type = "release";
        features.updateNotifications = false;
      };
    };
  in {
    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      jq
      makeWrapper
      nodejs
      python3
    ];
    
    buildInputs = with pkgs; [
      alsa-lib
      atk
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libappindicator-gtk3
      libcxx
      libdbusmenu
      libdrm
      libnotify
      libpulseaudio
      libuuid
      mesa
      nspr
      nss
      pango
      stdenv.cc.cc
      systemd
      # vulkan-extension-layer
      vulkan-loader
    ] ++ (with pkgs.xorg; [
      libX11
      libxcb
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libXrandr
      libXrender
      libXScrnSaver
      libXtst
    ]);
    
    preConfigure = ''
      cp ${buildInfo} buildInfo.json
    '';
    postBuild = ''
      mkdir code
      mv app/* code
      mv code app
      cp -r sources/translations app
    '';

    postInstall = ''
      mkdir -p $out/share/icons/hicolor
      for res in {24,48,64,128,256}; do
        mkdir -p $out/share/icons/hicolor/''${res}x''${res}
        ln -s $out/lib/node_modules/webcord/sources/assets/icons/app.png \
          $out/share/icons/hicolor/''${res}x''${res}/webcord.png
      done

      ln -s "${desktopItem}/share/applications" $out/share/
    '';

    postFixup = ''
      wrapProgram $out/bin/webcord \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland}}" \
        --prefix XDG_DATA_DIRS : "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/" \
        --prefix PATH : "${pkgs.xdg-utils}/bin"
    '';
  };
}
