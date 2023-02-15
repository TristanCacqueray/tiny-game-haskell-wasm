{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    ghc-wasm-meta.url = "gitlab:ghc/ghc-wasm-meta/be8febd209eb428ff7ad36ffc55cb69d64d6fcf8?host=gitlab.haskell.org";
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
