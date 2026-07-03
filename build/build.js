// Pre-compile the app: transpile preview/app.jsx (JSX source) -> preview/app.js
// (plain JS shipped to the browser). Uses the vendored @babel/standalone in
// Node, so there are NO extra npm dependencies. Run via `npm run build`.
const fs = require("fs");
const path = require("path");
const Babel = require(path.join(__dirname, "babel.min.js"));
const src = fs.readFileSync(path.join(__dirname, "..", "preview", "app.jsx"), "utf8");
const { code } = Babel.transform(src, { presets: ["react"] });
fs.writeFileSync(path.join(__dirname, "..", "preview", "app.js"), code);
console.log("built preview/app.js (" + (code.length / 1024).toFixed(1) + " KB)");
