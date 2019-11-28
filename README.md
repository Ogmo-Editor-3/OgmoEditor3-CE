<p align="center">
  <img src="assets/gfx/logo.png" alt="Ogmo Editor 3"/>
</p>

### Open Source 2D level editor written in Haxe!

# Getting Started

This project requires Node v10+, and will install various other dependencies automatically, including the haxe compiler.

### Node
* Install [Node](https://nodejs.org/)

## Build
```
npm i
npm run build
```
This builds the App and puts it in the `bin` directory. You can then start the app by running `npm start`, or by starting electron in the directory.

## Development
Speed up development by using Webpack's dev server! Running `npm run dev` builds the app, starts a server that will watch for changes in the project, then starts electron. If changes are found, Webpack will rebuild the source and refresh the app. If there are errors, they will show up in the app's DevTools.

While running the dev server, all code that is within `#if debug` conditionals are added in.

NOTES:
  * Changes to `App.hx` are not watched, and the app will need to manually be rebuilt if changes are made there.
  * The app will need to be rebuilt normally (`npm run build`) in order to run it again after using the dev server.

## Packaging
```
npm i
npm run build
npm run dist
```
This builds, then packages the App into an executable.

# Credits
 - Created by [Matt Thorson](https://twitter.com/mattthorson) and [Noel Berry](https://twitter.com/noelfb)
 - Icons & Logo by [Kyle Pulver](https://twitter.com/kylepulver)
 - Ported to Haxe and extended by [Caleb Cornett](https://twitter.com/thespydog), [Will Blanton](https://twitter.com/x01010111), and [Austin East](https://twitter.com/austinweast)
