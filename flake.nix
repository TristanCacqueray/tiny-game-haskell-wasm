{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    ghc-wasm-meta.url =
      "gitlab:ghc/ghc-wasm-meta/be8febd209eb428ff7ad36ffc55cb69d64d6fcf8?host=gitlab.haskell.org";
    # fetch the tiny-game-hs repository
    tiny-games-hs.url =
      "github:haskell-game/tiny-games-hs/9dcd6f220d265966bf1f1ca259b5aa956a4cc8a6";
    tiny-games-hs.flake = false;
  };
  outputs = { self, nixpkgs, ghc-wasm-meta, tiny-games-hs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      wasm-ghc = ghc-wasm-meta.packages."x86_64-linux".wasm32-wasi-ghc-gmp;
      wasmtime = ghc-wasm-meta.packages."x86_64-linux".wasmtime;

      mk-tiny-game = cat: name: arg1: arg2:
        pkgs.stdenv.mkDerivation {
          pname = "tiny-games-${cat}-${name}";
          version = "1";
          src = tiny-games-hs;
          unpackPhase = ''
            mkdir -p $out/bin
            export PATH=$PATH:${wasm-ghc}/bin
            arg1="${arg1}"
            arg2="${arg2}"
            dname=$src/${cat}/$(echo ${name} | cut -d. -f1)
            wasm32-wasi-ghc $arg1 $arg2 -i$dname -outputdir $TMPDIR \
                -o $out/bin/${name}.wasm $dname/${name}.hs
          '';
          dontStrip = true;
          dontInstall = true;
        };
      mk-tiny-game1 = mk-tiny-game;
      mk-tiny-game0 = cat: name: mk-tiny-game1 cat name "" "";

      tiny-games = [
        (mk-tiny-game0 "prelude" "guess1")
        (mk-tiny-game0 "prelude" "pure-doors")
        (mk-tiny-game1 "prelude" "fifteen" "-XPatternSynonyms" "-XLambdaCase")
        (mk-tiny-game0 "prelude" "chess")
        (mk-tiny-game0 "prelude" "sudoku")
        (mk-tiny-game1 "prelude" "matchmaking" "-cpp"
          "-DD=a=replicate;b=putStrLn;c=length;p=map;u=max(2)")
        (mk-tiny-game0 "prelude" "tiny-brot")
        (mk-tiny-game1 "prelude" "mini-othello" "-O2" "")
        (mk-tiny-game0 "prelude" "one-dot")
        (mk-tiny-game0 "prelude" "expressit")
        (mk-tiny-game0 "prelude" "life")
        (mk-tiny-game0 "prelude" "call-by-push-block")
        (mk-tiny-game0 "prelude" "companion")
        (mk-tiny-game1 "prelude" "hangman" "-XCPP" "-XMultiWayIf -XLambdaCase")
        (mk-tiny-game0 "prelude" "quine")
        (mk-tiny-game0 "base" "timing")
        (mk-tiny-game1 "base" "shoot" "-XLambdaCase" "")
        (mk-tiny-game0 "base" "log2048")
        (mk-tiny-game0 "base" "rhythm")
        (mk-tiny-game0 "base" "peyton-says")
        (mk-tiny-game0 "base" "acey-deucey")
        (mk-tiny-game0 "base" "flower-seeds")
        (mk-tiny-game1 "base" "lambda-ray" "-O2" "")
        (mk-tiny-game0 "base" "7up7down")
        (mk-tiny-game0 "base" "snake")
        (mk-tiny-game1 "base" "woosh.caves" "-XUnicodeSyntax" "")
        (mk-tiny-game1 "base" "woosh.forest" "-XUnicodeSyntax" "")
        (mk-tiny-game0 "default" "type-and-furious")
        (mk-tiny-game1 "default" "shmupemup" "-package ghc" "")
        (mk-tiny-game0 "default" "tsp")
        (mk-tiny-game0 "default" "lol")
        (mk-tiny-game0 "default" "space-invaders")
        (mk-tiny-game1 "default" "swish.easy" "-XUnicodeSyntax" "")
        (mk-tiny-game1 "default" "swish.survival" "-XUnicodeSyntax" "")
        (mk-tiny-game0 "default" "lc")
      ];
    in {
      packages."x86_64-linux".wasm = pkgs.symlinkJoin {
        name = "tiny-games-all";
        paths = tiny-games;
      };

      devShell."x86_64-linux" = pkgs.mkShell {
        buildInputs = [ wasm-ghc wasmtime pkgs.nodejs pkgs.esbuild ];
      };
    };
}
