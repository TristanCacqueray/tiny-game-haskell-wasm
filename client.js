// Adapted from https://github.com/bjorn3/browser_wasi_shim/blob/main/examples/rustc.html
// SPDX-License-Identifier: MIT
import { Terminal } from 'xterm';
import { Fd } from "./node_modules/@bjorn3/browser_wasi_shim/src/fd.js";
import { Fdstat } from "./node_modules/@bjorn3/browser_wasi_shim/src/wasi_defs.js";
import { strace } from "./node_modules/@bjorn3/browser_wasi_shim/src/strace.js"
import { WASI, File, PreopenDirectory } from "@bjorn3/browser_wasi_shim";

const term = new Terminal({
    convertEol: true,
});
term.open(document.getElementById('term'));
term.resize(80,50)

class XTermStdio extends Fd {
    constructor(term) {
        super();
        this.term = term;
    }
    fd_read(x, y) {
        console.log("Reading!", x, y)
        return { ret: 0 }
    }
    fd_fdstat_get() {
        console.log("FDSTAT")
        return { ret: -1, fdstat: new Fdstat() };
    }
    fd_write(view8, iovs) {
        let nwritten = 0;
        for (let iovec of iovs) {
            // console.log(iovec.buf_len, iovec.buf_len, view8.slice(iovec.buf, iovec.buf + iovec.buf_len));
            let buffer = view8.slice(iovec.buf, iovec.buf + iovec.buf_len);
            this.term.write(buffer);
            nwritten += iovec.buf_len;
        }
        return { ret: 0, nwritten };
    }
}

(async function () {
    term.writeln("\x1B[93mDownloading\x1B[0m");
    const wasm = await WebAssembly.compileStreaming(fetch("tiny-brot.wasm"));
    term.writeln("\x1B[93mInstantiating\x1B[0m");
    const fds = [
        new XTermStdio(term),
        new XTermStdio(term),
        new XTermStdio(term),
    ];
    const wasi = new WASI([], ["LC_ALL=en_US.utf-8"], fds);
    const inst = await WebAssembly.instantiate(wasm, {
        "wasi_snapshot_preview1": strace(wasi.wasiImport, ["fd_prestat_get"]),
    });
    term.writeln("\x1B[93mExecuting\x1B[0m");
    console.log(inst.exports);
    wasi.start(inst);
    term.writeln("\x1B[92mDone\x1B[0m");
})()
