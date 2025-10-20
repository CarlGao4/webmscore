
# webmscore

> MuseScore's libmscore (the core library) in WebAssembly!  

## Features

* Parse `mscz` file data
* Get score metadata
* Export part score
* Generate music sheets in SVG/PNG/PDF format
* Generate MIDI
* Generate audio files in WAV, OGG, MP3, or FLAC format
* Synthesize raw audio frames, can be used in the Web Audio API 
* Export as MusicXML compressed/uncompressed
* Generate position information of measures or segments on the generated sheets
* Run inside a Web Worker thread

## Installation

The package is available on npm: https://www.npmjs.com/package/webmscore

```sh
npm i webmscore
```

## Use webmscore

### Load in browsers

```html
<!-- using a CDN -->
<script src="https://cdn.jsdelivr.net/npm/webmscore/webmscore.js"></script>
<script>
    WebMscore.ready.then(async () => {
        const score = await WebMscore.load('mscz', msczdata)
    })
</script>
```

For latest browsers which support ES Modules

```js
import WebMscore from 'https://cdn.jsdelivr.net/npm/webmscore/webmscore.mjs'
```

### Run in Node.js directly

Minimum version: v8.9.0 with ES Modules support

The `--experimental-modules` flag is required for Node.js versions under 14,  
Also require `"type": "module"` in `package.json`

Node.js greater or equal to v18 is not supported. Node.js v16 is recommended.

```js
import WebMscore from 'webmscore'
WebMscore.ready.then(async () => {
    const score = await WebMscore.load('mscz', msczdata)
})
```

### Use a JavaScript bundler

*(TBD)*

### Load extra fonts

If your score sheet contains characters out of the range of the bundled [FreeFont](https://www.gnu.org/software/freefont/), those characters will be shown as tofu characters (`□` or `�`) in SVG/PNG/PDF files. Loading extra fonts is required.

webmscore can load any font format supported by [FreeType](https://www.freetype.org/freetype2/docs/index.html).

```js
const score = await WebMscore.load('mscz', msczdata, [...arrOfFontData])
```

> CJK fonts are no longer bundled inside webmscore since v0.6.0

### Load soundfont files

Loading a soudfont (sf2/sf3) file is required before generating/synthesizing audio.

```js
await score.setSoundFont(soudfontData)
```

Soudfonts can be found on [musescore.org website](https://musescore.org/en/handbook/soundfonts-and-sfz-files#list).

Example: (`FluidR3Mono_GM.sf3`)

```js
const soudfontData = new Uint8Array(
    await (
        await fetch('https://cdn.jsdelivr.net/gh/musescore/MuseScore@2.1/share/sound/FluidR3Mono_GM.sf3')
    ).arrayBuffer()
)
```

### Boost Mode

Sometimes you only want to process a bunch of score metadata, so drawing sheet images internally is a waste of time and system resource.

You can enable the Boost Mode by setting the `doLayout` parameter in `WebMscore.load` to `false`.

Example:

```js
const score = await WebMscore.load('mscz', msczdata, [], false)
const metadata = await score.metadata()
score.destroy()
```

webmscore's Boost Mode is about 3x faster than the batch converter feature (`-j`) of the musescore software, according to the [benchmark](./web-example/benchmark.js) result.

WebAssembly vs native C++ program!

## Compiling

1. Install essential tools like `make`, `cmake`, `llvm`, etc.

2. Install `emscripten` v2.0.6 using `emsdk`
https://emscripten.org/docs/getting_started/downloads.html

3. Get Qt5 for WebAssembly and apply patches

```sh
AQT_PREFIX=$PWD/build.qt6
Qt6_VER=6.9.1
# if you change the install directory or Qt version, remember to also change the variables in `web/Makefile` file

# Download Qt using aqtinstall (https://github.com/miurahr/aqtinstall)
pip install aqtinstall
aqt install-qt all_os wasm ${Qt6_VER} wasm_singlethread --autodesktop --outputdir ${AQT_PREFIX} --archives qtbase qtdeclarative qtsvg --modules qt5compat qtscxml qtshadertools

# If you encounter libicui18n.so not found error during the build, you may need to install ICU from aqt
# If you are not using Linux, adjust the platform name accordingly
aqt install-qt linux desktop ${Qt6_VER} --outputdir ${AQT_PREFIX} --archives icu
```

4. Compile `webmscore`

```sh
cd web-public
npm i
npm run build
```

Build artifacts are in the [web-public](./web-public) directory

## Browser Support 

All modern browsers which support [WebAssembly](https://caniuse.com/#feat=wasm) and [Async Functions](https://caniuse.com/#feat=async-functions)

| Name | Minimum Version |
|---|---|
| Chrome | 57 |
| Firefox | 53, 52 (non-ESR) |
| Edge | 16 (Fall Creators Update) |
| Safari | 11 |
| IE | NO! |
| Other browsers | I don't know! |

Only tested on the latest version of Chrome and Firefox.

## Examples

see files in the [web-example](./web-example) directory

```sh
cd ./web-example
npm i
npm start  # Node.js example
npm run start:browser  # browser example
```

## Debugging

See [How to look up function names in the .symbols file?](https://github.com/LibreScore/webmscore/blob/web/CHANGELOG.md#0192---2021-01-25)

---

webmscore is part of the [LibreScore](https://github.com/LibreScore/) project.
