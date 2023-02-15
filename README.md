# tiny-game-haskell-wasm

A WIP proof of concept to run [tiny-game-hs](https://github.com/haskell-game/tiny-games-hs) in the browser.

## Usage

```ShellSession
# Install toolchain
$ nix develop

# Build wasm module
$ wasm32-wasi-ghc tiny-brot.hs -o dist/tiny-brot.wasm

# Build JS client
$ npm install && npm run bundle

# Copy index
$ cp index.html dist

# Serve browser
$ (cd dist; python3 -m http.server)

# Browse
$ firefox http://localhost:8000
```

## Limitations

- stdin does not work
- wasi.js `poll_oneoff` needs to be patched to replace `throw "async io not supported"` with `return 1`.
