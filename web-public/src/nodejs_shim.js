
import { createRequire } from 'module'
import { dirname } from 'path'
import { fileURLToPath } from 'url'
import { IS_NODE, shimDom } from './utils.js'

if (IS_NODE) {

    // cjs require for the native Node.js ES Modules support
    if (typeof require == "undefined") {
        global.require = createRequire(import.meta.url)
    }

    // __dirname for the native Node.js ES Modules support
    if (typeof __dirname == "undefined") {
        global.__dirname = dirname(fileURLToPath(import.meta.url))
    }

    // Provide a minimal in-memory IndexedDB implementation for IDBFS in Node.js.
    require("fake-indexeddb/auto");

    shimDom()
}
