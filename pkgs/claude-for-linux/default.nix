# Claude Desktop for Linux with Cowork support
# Usage: callPackage ./pkgs/claude-for-linux { }
{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  symlinkJoin,
  electron,
  bubblewrap,
  dmg2img,
  p7zip,
  python3,
  nodejs,
  perl,
  buildFHSEnv,
  writeScriptBin,
}:

let
  pname = "claude-desktop";
  version = "1.1.3770";

  claudeSrc = fetchurl {
    url = "https://downloads.claude.ai/releases/darwin/universal/${version}/Claude-f7f5859a17386e383fad75f35ff6dd0f6e9dfd66.dmg";
    hash = "sha256-dx+lYjSYN1vRMKGQdNYFJwxZAwfyoLjxlJUKd29c6+Y=";
  };

  asarTool = writeScriptBin "asar-tool" ''
    #!${python3}/bin/python3
    ${builtins.readFile ./tools/asar_tool.py}
  '';

  claudeApp = stdenv.mkDerivation {
    pname = "claude-desktop-app";
    inherit version;

    src = claudeSrc;

    nativeBuildInputs = [
      dmg2img
      p7zip
      python3
      nodejs
      perl
    ];

    dontUnpack = true;

    buildPhase = ''
      runHook preBuild

      echo "=== Extracting Claude Desktop ${version} ==="

      # Convert DMG to IMG
      echo "[1/6] Converting DMG to IMG..."
      dmg2img $src claude.img

      # Extract with 7z
      echo "[2/6] Extracting IMG..."
      mkdir -p dmg-contents
      7z x -y -odmg-contents claude.img > /dev/null 2>&1 || true

      # Find app.asar
      echo "[3/6] Locating app.asar..."
      APP_ASAR=$(find dmg-contents -name "app.asar" -path "*/Contents/Resources/*" | head -1)
      if [ -z "$APP_ASAR" ]; then
        echo "ERROR: app.asar not found in DMG"
        exit 1
      fi
      echo "  Found: $APP_ASAR"

      RESOURCES_DIR="$(dirname "$APP_ASAR")"

      # Extract ASAR
      echo "[4/6] Extracting ASAR..."
      mkdir -p extracted
      ${asarTool}/bin/asar-tool extract "$APP_ASAR" extracted

      # Copy i18n resources
      echo "  Copying i18n resources..."
      mkdir -p extracted/resources/i18n
      for json in "$RESOURCES_DIR"/*.json; do
        if [ -f "$json" ]; then
          cp "$json" extracted/resources/i18n/
        fi
      done

      # Copy tray icons
      echo "  Copying tray icons..."
      for icon in "$RESOURCES_DIR"/TrayIcon*.png "$RESOURCES_DIR"/Tray-Win32*.ico "$RESOURCES_DIR"/EchoTray*.png; do
        if [ -f "$icon" ]; then
          cp "$icon" extracted/resources/
        fi
      done

      # Extract app icon from ICNS
      echo "  Extracting app icons from ICNS..."
      ICNS_FILE="$RESOURCES_DIR/electron.icns"
      if [ -f "$ICNS_FILE" ]; then
        mkdir -p icon-extracted
        ${python3}/bin/python3 ${./tools/icns_extract.py} "$ICNS_FILE" icon-extracted
        if [ -f icon-extracted/256.png ]; then
          cp icon-extracted/256.png extracted/resources/icon.png
        fi
      fi

      # Apply patches
      echo "[5/6] Applying patches..."

      INDEX="extracted/.vite/build/index.js"
      MAINVIEW="extracted/.vite/build/mainView.js"

      # Patch 00: Native module stub
      echo "[patch:00] Installing native module stub..."
      mkdir -p extracted/node_modules/@ant/claude-native
      cp ${./modules/enhanced-claude-native-stub.js} extracted/node_modules/@ant/claude-native/index.js
      cat > extracted/node_modules/@ant/claude-native/package.json <<STUBPKG
      {"name":"@ant/claude-native","version":"1.0.0-linux-stub","main":"index.js"}
      STUBPKG
      echo "[patch:00] Done"

      # Patch 01: Cowork module loader
      echo "[patch:01] Installing cowork module..."
      mkdir -p extracted/node_modules/claude-cowork-linux
      cp ${./modules/claude-cowork-linux.js} extracted/node_modules/claude-cowork-linux/index.js
      cat > extracted/node_modules/claude-cowork-linux/package.json <<COWORKPKG
      {"name":"claude-cowork-linux","version":"2.0.0","main":"index.js"}
      COWORKPKG
      cat ${./scripts/cowork-init.js} >> "$INDEX"
      echo "[patch:01] Done"

      # Patch 02: Platform flag
      echo "[patch:02] Patching platform flag..."
      perl -i -pe 's{(\w+=process\.platform==="darwin",)(\w+)(=process\.platform==="win32")}{$1$2$3||process.platform==="linux"}g' "$INDEX"
      echo "[patch:02] Done"

      # Patch 03: Availability check
      echo "[patch:03] Patching availability check..."
      perl -i -pe 's{(function )(\w+)(\(\)\{)(const t=process\.platform;if\(t!=="darwin"&&t!=="win32"\)return\{status:"unsupported")}{$1$2$3if(process.platform==="linux"\&\&global.__linuxCowork)return\{status:"supported"\};$4}g' "$INDEX"
      echo "[patch:03] Done"

      # Patch 04: Skip download
      echo "[patch:04] Patching download skip..."
      perl -i -pe 's{(async function \w+\(t,e\)\{)(.{0,200}?\[downloadVM\])}{$1if(process.platform==="linux"\&\&global.__linuxCowork){console.log("[Cowork Linux] Skipping bundle download");return!1}$2}g' "$INDEX"
      echo "[patch:04] Done"

      # Patch 05: VM start intercept (with fix for HJe() call)
      echo "[patch:05] Patching VM start intercept..."
      ${nodejs}/bin/node ${./scripts/patch-vm-start.js} extracted
      echo "[patch:05] Done"

      # Patch 06a: VM getter
      echo "[patch:06a] Patching VM getter..."
      perl -i -pe 's{(async function )(\w+)(\(\)\{)(const \w+=await \w+\(\);return\(\w+==null\?void 0:\w+\.vm\)\?\?null)}{$1$2$3if(process.platform==="linux"\&\&global.__linuxCowork\&\&global.__linuxCowork.vmInstance){console.log("[Cowork Linux] $2() returning Linux VM");return global.__linuxCowork.vmInstance}$4}g' "$INDEX"
      echo "[patch:06a] Done"

      # Patch 06b: Platform getter
      echo "[patch:06b] Patching platform getter..."
      perl -i -pe 's{(async function \w+\(\)\{return )process\.platform!=="darwin"\?null(:await \w+\(\))}{''${1}process.platform!=="darwin"\&\&process.platform!=="linux"?null''${2}}g' "$INDEX"
      echo "[patch:06b] Done"

      # Patch 07: Platform branding
      echo "[patch:07] Injecting platform branding fix..."
      cat ${./scripts/branding-fix.js} >> "$MAINVIEW"
      echo "[patch:07] Done"

      # Patch 08a: Tray icon resource path (non-fatal)
      echo "[patch:08a] Patching tray icon resource path..."
      perl -i -pe 's{function (\w+)\(\)\{return (\w+)\.app\.isPackaged\?(\w+)\.resourcesPath:(\w+)\.resolve\(__dirname,"\.\.","\.\.","resources"\)\}}{function $1(){return process.platform==="linux"?$4.join($4.dirname($2.app.getAppPath()),"resources"):$2.app.isPackaged?$3.resourcesPath:$4.resolve(__dirname,"..","..","resources")}}g' "$INDEX" || true
      echo "[patch:08a] Done"

      # Patch 08b: Tray icon filename (non-fatal)
      echo "[patch:08b] Patching tray icon filename selection..."
      perl -i -pe 's{(\w+)\?(\w+)=(\w+)\.nativeTheme\.shouldUseDarkColors\?"Tray-Win32-Dark\.ico":"Tray-Win32\.ico":(\w+)="TrayIconTemplate\.png"}{process.platform==="linux"?($2=$3.nativeTheme.shouldUseDarkColors?"TrayIconTemplate-Dark.png":"TrayIconTemplate.png"):$1?$2=$3.nativeTheme.shouldUseDarkColors?"Tray-Win32-Dark.ico":"Tray-Win32.ico":$4="TrayIconTemplate.png"}g' "$INDEX" || true
      echo "[patch:08b] Done"

      # Patch 09: DBus tray cleanup delay - DISABLED
      # This patch attempted to add `await new Promise(...)` but the target code
      # is not in an async function, causing a SyntaxError. Skipping.
      echo "[patch:09] Skipped (not compatible with this version)"

      # Repack ASAR
      echo "[6/6] Repacking ASAR..."
      ${asarTool}/bin/asar-tool pack extracted app.asar

      echo "=== Build complete ==="

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/claude-desktop
      cp app.asar $out/lib/claude-desktop/

      # Copy unpacked resources if they exist
      APP_UNPACKED="$(dirname $(find dmg-contents -name 'app.asar' -path '*/Contents/Resources/*' | head -1))/app.asar.unpacked"
      if [ -d "$APP_UNPACKED" ]; then
        cp -r "$APP_UNPACKED" $out/lib/claude-desktop/app.asar.unpacked
      fi

      # Copy tray icons to filesystem (for COSMIC SNI compatibility)
      mkdir -p $out/lib/claude-desktop/resources
      for icon in extracted/resources/TrayIconTemplate*.png extracted/resources/icon.png; do
        if [ -f "$icon" ]; then
          cp "$icon" $out/lib/claude-desktop/resources/
        fi
      done

      # Install hicolor theme icons
      if [ -d icon-extracted ]; then
        for png in icon-extracted/*.png; do
          size=$(basename "$png" .png)
          if [ "$size" -gt 0 ] 2>/dev/null; then
            mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps"
            cp "$png" "$out/share/icons/hicolor/''${size}x''${size}/apps/claude.png"
          fi
        done
      fi

      runHook postInstall
    '';
  };

in symlinkJoin {
  name = "${pname}-${version}";
  paths = [ claudeApp ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    mkdir -p $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/claude-desktop \
      --add-flags "$out/lib/claude-desktop/app.asar" \
      --add-flags "--no-sandbox" \
      --add-flags "--ozone-platform-hint=auto" \
      --add-flags "--class=Claude" \
      --prefix PATH : ${lib.makeBinPath [ bubblewrap ]} \
      --set BWRAP_PATH "${bubblewrap}/bin/bwrap" \
      --set CHROME_DESKTOP "claude-desktop.desktop" \
      --prefix XDG_DATA_DIRS : "$out/share"

    # Desktop entry
    mkdir -p $out/share/applications
    cat > $out/share/applications/claude-desktop.desktop <<DESKTOP
[Desktop Entry]
Name=Claude
Comment=Claude AI Assistant with Cowork
Exec=$out/bin/claude-desktop %U
Icon=claude
Type=Application
Categories=Development;Utility;
MimeType=x-scheme-handler/claude;
StartupWMClass=Claude
DESKTOP
  '';

  meta = with lib; {
    description = "Claude Desktop for Linux with Cowork support";
    homepage = "https://claude.ai";
    license = licenses.unfree;
    platforms = platforms.linux;
    mainProgram = "claude-desktop";
  };
}
