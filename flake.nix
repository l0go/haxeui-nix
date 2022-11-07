{
  description = "A template for HaxeUI Projects"; # <--- EDIT THIS!
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      projectName = "haxeui-nix"; # <--- EDIT THIS!
      projectVersion = "2022-11-7"; # <--- EDIT THIS!
      pkgs = nixpkgs.legacyPackages.${system};
      withCommas = with import nixpkgs { system = system; }; lib.replaceChars ["."] [","];
      concatHaxelibs = ''
        ( IFS=:;
          mkdir $TMP/haxe
          for p in $HAXELIB_PATH; do
            cp -r "$p" $TMP
          done
        )
        HAXELIB_PATH=$TMP/haxe'';
    in {
      packages.hxcpp = 
        with import nixpkgs { system = system; };
        haxePackages.buildHaxeLib rec {
          libname = "hxcpp";
          version = "4.2.1";
          sha256 = "sha256-F9JQMqnKgU59wdXFFZ8Rjt3u3XkwPjDeMgRSFzlaMoI=";
          postFixup = ''
            for f in $out/lib/haxe/${withCommas libname}/${withCommas version}/{,project/libs/nekoapi/}bin/Linux{,64}/*; do
              chmod +w "$f"
              patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker)   "$f" || true
              patchelf --set-rpath ${ lib.makeLibraryPath [ stdenv.cc.cc ] }  "$f" || true
            done
          '';
          meta.description = "Runtime support library for the Haxe C++ backend";
      };

      packages.haxeui-core =
        with import nixpkgs { system = system; };
        let
          libname = "haxeui-core";
          version = "git";
        in
        stdenv.mkDerivation {
          name = "${libname}-${version}";
          src = pkgs.fetchFromGitHub {
            owner = "haxeui";
            repo = "haxeui-core";
            rev = "49dcc02";
            sha256 = "0jsqmwhj2q58fsgla7cwci553bcf64xzkzfi04ywiziqna8y8mxh";
          };
          installPhase = haxePackages.installLibHaxe { inherit libname version; };
          meta = {
            homepage = "http://haxeui.org/";
            license = lib.licenses.mit;
            platforms = lib.platforms.all;
            description = "The core library of the HaxeUI framework";
          };
        };
      
      packages.haxeui-hxwidgets =
        with import nixpkgs { system = system; };
        let
          libname = "haxeui-hxwidgets";
          version = "git";
        in
        stdenv.mkDerivation {
          name = "${libname}-${version}";
          src = pkgs.fetchFromGitHub {
            owner = "haxeui";
            repo = "haxeui-hxwidgets";
            rev = "7e2f3c6";
            sha256 = "1dw5j5ic2dparx89y099ibqqkj8dgxaz7b5cr4qah1x1b56fkr85";
          };
          installPhase = haxePackages.installLibHaxe { inherit libname version; };
          meta = {
            homepage = "http://haxeui.org/";
            license = lib.licenses.mit;
            platforms = lib.platforms.all;
            description = "The hxWidgets backend of the HaxeUI framework";
          };
        };
        
        packages.hxwidgets =
        with import nixpkgs { system = system; };
        let
          libname = "hxwidgets";
          version = "git";
        in
        stdenv.mkDerivation {
          name = "${libname}-${version}";
          src = pkgs.fetchFromGitHub {
            owner = "haxeui";
            repo = "hxwidgets";
            rev = "f2c012d";
            sha256 = "0pal8jxmi3qpsas9gjxqfqyiqhw1aamx003n9qw416xkp6fykilf";
          };
          installPhase = haxePackages.installLibHaxe { inherit libname version; };
          meta = {
            homepage = "http://haxeui.org/";
            license = lib.licenses.mit;
            platforms = lib.platforms.all;
            description = "Haxe externs (and wrappers) for wxWidgets";
          };
        }; 
        
      packages.app = with import nixpkgs { system = system; }; pkgs.stdenv.mkDerivation rec {
        pname = projectName;
        version = projectVersion;
        src = ./.;
        nativeBuildInputs = [ pkgs.haxe pkgs.wxGTK32 clang self.packages.${system}.hxcpp self.packages.${system}.haxeui-core self.packages.${system}.haxeui-hxwidgets self.packages.${system}.hxwidgets ] ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Cocoa ];
        patchPhase = concatHaxelibs;
        postPatch = lib.optionalString stdenv.isDarwin ''
          chmod +w $TMP/haxe/hxcpp/4,2,1/toolchain/
          sed -i 's/xcrun --sdk macosx.\{14\}//g' $TMP/haxe/hxcpp/4,2,1/toolchain/mac-toolchain.xml
        '';
        buildPhase = ''
          runHook postPatch
          export HXCPP_CONFIG=$(mktemp -d)/.config.xml
          export HXCPP_VERBOSE=
          export HXCPP_CLANG=  
          export DEVELOPER_DIR=$out
          haxe hxwidgets.hxml
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp Build/hxwidgets/Main $out/bin
        '';
      };
      
      defaultPackage = self.packages.${system}.app;

      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [ haxe wxGTK32 clang self.packages.${system}.hxcpp self.packages.${system}.haxeui-core self.packages.${system}.haxeui-hxwidgets self.packages.${system}.hxwidgets ];
        shellHook = concatHaxelibs;
      };
    });
}
