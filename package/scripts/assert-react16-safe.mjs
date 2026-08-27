// Guards React 16 support. Two things break older consumers:
//   1. `react/jsx-runtime` only exists from React 16.14, so the bundle must use
//      the classic React.createElement transform (see tsup.config.ts).
//   2. React 16-era apps are usually on webpack 4 (CRA 4, Next 9/10), whose acorn
//      cannot parse `?.` / `??`. tsup targets es2017 to avoid emitting them.
import { readFileSync } from "node:fs";

const CHECKS = [
  { name: "react/jsx-runtime import (breaks React < 16.14)", re: /react\/jsx-runtime/ },
  { name: "ES2020 syntax `?.` or `??` (breaks webpack 4)", re: /\?\.[a-zA-Z_$[(]|\?\?[^)]/ },
];

let failed = false;
for (const file of ["dist/index.js", "dist/index.mjs"]) {
  const code = readFileSync(file, "utf8");
  for (const { name, re } of CHECKS) {
    if (re.test(code)) {
      console.error(`${file}: ${name}`);
      failed = true;
    }
  }
}

if (failed) {
  console.error("Fix tsup.config.ts (jsx transform / target) before publishing.");
  process.exit(1);
}
