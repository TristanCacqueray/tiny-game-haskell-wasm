{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    ghc-wasm-meta.url = "git+https://gitlab.haskell.org/ghc/ghc-wasm-meta";
  };
  outputs = { self, nixpkgs, ghc-wasm-meta }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      wasm-ghc = ghc-wasm-meta.packages."x86_64-linux".wasm32-wasi-ghc-gmp;

    in {
      devShell."x86_64-linux" =
        pkgs.mkShell { buildInputs = [ wasm-ghc pkgs.nodejs pkgs.esbuild ]; };
    };
}
